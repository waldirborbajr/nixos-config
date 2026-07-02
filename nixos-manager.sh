#!/usr/bin/env bash
#
# nixos-manager.sh — gerencia rebuilds, cache e updates do NixOS
#
# sudo mv /etc/nixos /etc/nixos.bak   # backup
# sudo ln -s /home/borba/nixos-config /etc/nixos
#
# Uso:
#   ./nixos-manager.sh                    # abre o menu interativo
#   ./nixos-manager.sh <opcao>             # roda direto: legacy | flake | clean | update
#   ./nixos-manager.sh <opcao> <host>      # roda direto num host específico: flake dell
#   NIXOS_FLAKE_ATTR=dell ./nixos-manager.sh flake   # força o host via env var
#
# Requisitos: repo git em /etc/nixos com o flake configurado (branch m2config).
#
# Hosts conhecidos (definidos no flake.nix -> nixosConfigurations):
#   m2utm       (macutm)    aarch64-linux
#   dell        (dell1456)  x86_64-linux
#   macbook2011 (mac2011)   x86_64-linux

set -euo pipefail

NIXOS_DIR="/home/borba/nixos-config"
GIT_BRANCH="m2config"

# attr do flake -> nome real da máquina (usado pra auto-detecção via `hostname`)
declare -A HOST_ATTR_TO_MACHINE=(
  [m2utm]="macutm"
  [dell]="dell1456"
  [macbook2011]="mac2011"
)
FLAKE_ATTRS=(m2utm dell macbook2011)

# selecionado em runtime por select_flake_attr()
FLAKE_ATTR=""

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

# ----- seleção de host/máquina -----

detect_flake_attr() {
  # tenta casar o hostname real da máquina com um attr do flake
  local machine
  machine="$(hostname -s 2>/dev/null || cat /etc/hostname 2>/dev/null || true)"
  [ -z "$machine" ] && return 1

  local attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    if [ "${HOST_ATTR_TO_MACHINE[$attr]}" = "$machine" ]; then
      echo "$attr"
      return 0
    fi
  done
  return 1
}

prompt_flake_attr() {
  echo "Hosts disponíveis:" >&2
  local i=1 attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo "  $i) $attr (${HOST_ATTR_TO_MACHINE[$attr]})" >&2
    i=$((i + 1))
  done
  local choice
  read -r -p "Escolha o host [1-${#FLAKE_ATTRS[@]}]: " choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#FLAKE_ATTRS[@]}" ]; then
    echo "${FLAKE_ATTRS[$((choice - 1))]}"
    return 0
  fi
  return 1
}

# select_flake_attr [host_arg]
# prioridade: arg explícito > env NIXOS_FLAKE_ATTR > auto-detecção via hostname > prompt interativo
select_flake_attr() {
  local host_arg="${1:-}"

  if [ -n "$host_arg" ]; then
    if [[ " ${FLAKE_ATTRS[*]} " == *" $host_arg "* ]]; then
      FLAKE_ATTR="$host_arg"
      return 0
    else
      err "Host desconhecido: $host_arg (opções: ${FLAKE_ATTRS[*]})"
      exit 1
    fi
  fi

  if [ -n "${NIXOS_FLAKE_ATTR:-}" ]; then
    if [[ " ${FLAKE_ATTRS[*]} " == *" $NIXOS_FLAKE_ATTR "* ]]; then
      FLAKE_ATTR="$NIXOS_FLAKE_ATTR"
      return 0
    else
      warn "NIXOS_FLAKE_ATTR='$NIXOS_FLAKE_ATTR' inválido, ignorando."
    fi
  fi

  local detected
  if detected="$(detect_flake_attr)"; then
    FLAKE_ATTR="$detected"
    ok "Host detectado automaticamente: $FLAKE_ATTR (${HOST_ATTR_TO_MACHINE[$FLAKE_ATTR]})"
    return 0
  fi

  warn "Não foi possível detectar o host automaticamente (hostname atual: $(hostname -s 2>/dev/null || echo '?'))."
  if FLAKE_ATTR="$(prompt_flake_attr)"; then
    return 0
  fi

  err "Nenhum host selecionado."
  exit 1
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
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  git_sync_pull
  log "Build COM flake (${NIXOS_DIR}#${FLAKE_ATTR})..."
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Rebuild (flake) concluído em ${FLAKE_ATTR}."
  git_sync_push
}

build_flake_dry() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  git_sync_pull
  log "Build de teste (sem aplicar) para ${NIXOS_DIR}#${FLAKE_ATTR}..."
  sudo nixos-rebuild build --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Build de teste concluído — nada foi ativado. Resultado em ./result"
}

update_system() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"
  git_sync_pull
  log "Atualizando flake.lock (nix flake update)..."
  sudo nix flake update
  log "Aplicando update via rebuild switch --flake (${FLAKE_ATTR})..."
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Sistema atualizado em ${FLAKE_ATTR}."
  git_sync_push
}

rollback_system() {
  log "Gerações disponíveis:"
  sudo nix-env --list-generations -p /nix/var/nix/profiles/system
  if confirm "Fazer rollback para a geração anterior?"; then
    sudo nixos-rebuild switch --rollback
    ok "Rollback concluído."
  else
    warn "Cancelado."
  fi
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

check_flake() {
  require_dir
  cd "$NIXOS_DIR"
  log "Verificando flake (nix flake check)..."
  nix flake check
  ok "Flake válido."
}

list_hosts() {
  echo -e "${C_BOLD}Hosts configurados no flake:${C_RESET}"
  local attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo "  - $attr  (hostname: ${HOST_ATTR_TO_MACHINE[$attr]})"
  done
  local detected
  if detected="$(detect_flake_attr)"; then
    echo
    ok "Esta máquina corresponde a: $detected"
  else
    echo
    warn "Esta máquina ($(hostname -s 2>/dev/null || echo '?')) não corresponde a nenhum host conhecido."
  fi
}

# ----- menu -----

show_menu() {
  echo
  echo -e "${C_BOLD}NixOS Manager${C_RESET}"
  echo "  1) Build sem flake     (nixos-rebuild switch)"
  echo "  2) Build com flake     (pull → rebuild --flake → commit/push)"
  echo "  3) Limpar cache        (nix-collect-garbage + optimise)"
  echo "  4) Atualizar sistema   (flake update → rebuild → commit/push)"
  echo "  5) Build de teste      (nixos-rebuild build, não ativa nada)"
  echo "  6) Rollback            (voltar para geração anterior)"
  echo "  7) Verificar flake     (nix flake check)"
  echo "  8) Listar hosts        (mostra hosts do flake e detecção atual)"
  echo "  0) Sair"
  echo
}

run_choice() {
  local choice="$1"
  local host_arg="${2:-}"
  case "$choice" in
    1|legacy)  build_legacy ;;
    2|flake)   build_flake "$host_arg" ;;
    3|clean)   clean_cache ;;
    4|update)  update_system "$host_arg" ;;
    5|dry)     build_flake_dry "$host_arg" ;;
    6|rollback) rollback_system ;;
    7|check)   check_flake ;;
    8|hosts)   list_hosts ;;
    0|exit|quit) exit 0 ;;
    *) err "Opção inválida: $choice"; return 1 ;;
  esac
}

main() {
  if [ $# -ge 1 ]; then
    run_choice "$1" "${2:-}"
    exit $?
  fi

  while true; do
    show_menu
    read -r -p "Escolha uma opção: " choice
    run_choice "$choice" || true
  done
}

main "$@"
