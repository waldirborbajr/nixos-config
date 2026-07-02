#!/usr/bin/env bash
#
# nixos-manager.sh — gerencia rebuilds, cache e updates do NixOS
#
# sudo mv /etc/nixos /etc/nixos.bak   # backup 
# sudo ln -s /home/borba/nixos-config /etc/nixos
# 
# Uso:
#   ./nixos-manager.sh            # abre o menu interativo
#   ./nixos-manager.sh <opcao>    # roda direto: legacy | flake | clean | update
#
# Requisitos: repo git em /etc/nixos com o flake configurado (branch m2config).

set -euo pipefail

NIXOS_DIR="/home/borba/nixos-config"
FLAKE_ATTR="nixos"
GIT_BRANCH="m2config"

# ----- cores (desativa se não for terminal interativo) -----
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'
  C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'; C_BLUE='\033[34m'
else
  C_RESET=''; C_BOLD=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''
fi

log()  { echo -e "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; }
ok()   { echo -e "${C_GREEN}✓${C_RESET} $*"; }
warn() { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
err()  { echo -e "${C_RED}✗${C_RESET} $*" >&2; }

require_dir() {
  if [ ! -d "$NIXOS_DIR" ]; then
    err "Diretório $NIXOS_DIR não encontrado."
    exit 1
  fi
}

check_etc_symlink() {
  # nixos-rebuild switch (modo legacy, sem --flake) procura config em
  # /etc/nixos por padrão. Como o repo vive em $NIXOS_DIR, isso só funciona
  # de fato se /etc/nixos for um symlink apontando pra lá.
  if [ -L /etc/nixos ] && [ "$(readlink -f /etc/nixos)" = "$(readlink -f "$NIXOS_DIR")" ]; then
    return 0
  fi
  return 1
}

confirm() {
  # confirm "pergunta" -> retorna 0 se sim
  local prompt="$1"
  read -r -p "$prompt [s/N] " reply
  [[ "$reply" =~ ^[SsYy]$ ]]
}

# ----- git helpers -----

git_sync_pull() {
  cd "$NIXOS_DIR"
  log "Puxando alterações do branch $GIT_BRANCH..."
  git pull origin "$GIT_BRANCH"
}

git_sync_push() {
  cd "$NIXOS_DIR"
  if [ -z "$(git status --porcelain)" ]; then
    ok "Nada para commitar — árvore de trabalho limpa."
    return 0
  fi

  git status --short
  if ! confirm "Commitar e enviar essas alterações para $GIT_BRANCH?"; then
    warn "Push cancelado pelo usuário. Alterações locais permanecem sem versionar."
    return 0
  fi

  git add -A
  read -r -p "Mensagem do commit [lock: update]: " msg
  msg="${msg:-lock: update}"
  git commit -m "$msg"
  git push origin "$GIT_BRANCH"
  ok "Push concluído."
}

# ----- ações principais -----

build_legacy() {
  require_dir
  log "Build SEM flake (channels clássicos)..."

  if check_etc_symlink; then
    sudo nixos-rebuild switch
  else
    warn "/etc/nixos não é um symlink para $NIXOS_DIR — usando -I nixos-config explícito."
    sudo nixos-rebuild switch -I nixos-config="${NIXOS_DIR}/configuration.nix"
  fi

  ok "Rebuild (legacy) concluído."
}

build_flake() {
  require_dir
  git_sync_pull
  log "Build COM flake (${NIXOS_DIR}#${FLAKE_ATTR})..."
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Rebuild (flake) concluído."
  git_sync_push
}

update_system() {
  require_dir
  cd "$NIXOS_DIR"
  git_sync_pull
  log "Atualizando flake.lock (nix flake update)..."
  sudo nix flake update
  log "Aplicando update via rebuild switch --flake..."
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Sistema atualizado."
  git_sync_push
}

clean_cache() {
  log "Limpando gerações antigas e coletando lixo do Nix store..."
  echo "  1) Rápido   — remove gerações com mais de 14 dias"
  echo "  2) Agressivo — remove TODAS as gerações antigas (nix-collect-garbage -d)"
  read -r -p "Escolha [1/2]: " mode

  case "$mode" in
    1)
      sudo nix-collect-garbage --delete-older-than 14d
      ;;
    2)
      if confirm "Isso remove TODAS as gerações antigas, inclusive rollback. Confirma?"; then
        sudo nix-collect-garbage -d
      else
        warn "Cancelado."
        return 0
      fi
      ;;
    *)
      err "Opção inválida."
      return 1
      ;;
  esac

  log "Otimizando store (deduplicação de hardlinks)..."
  sudo nix-store --optimise
  ok "Limpeza concluída."

  log "Espaço em disco atual:"
  df -h /nix/store 2>/dev/null || df -h /
}

# ----- menu -----

show_menu() {
  echo
  echo -e "${C_BOLD}NixOS Manager${C_RESET}"
  echo "  1) Build sem flake   (nixos-rebuild switch)"
  echo "  2) Build com flake   (pull → rebuild --flake → commit/push)"
  echo "  3) Limpar cache      (nix-collect-garbage + optimise)"
  echo "  4) Atualizar sistema (flake update → rebuild → commit/push)"
  echo "  0) Sair"
  echo
}

run_choice() {
  case "$1" in
    1|legacy) build_legacy ;;
    2|flake)  build_flake ;;
    3|clean)  clean_cache ;;
    4|update) update_system ;;
    0|exit|quit) exit 0 ;;
    *) err "Opção inválida: $1"; return 1 ;;
  esac
}

main() {
  if [ $# -ge 1 ]; then
    run_choice "$1"
    exit $?
  fi

  while true; do
    show_menu
    read -r -p "Escolha uma opção: " choice
    run_choice "$choice" || true
  done
}

main "$@"
