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
#
# Fluxo de "flake"/"update": commit local (se houver algo pendente) → pull →
# [flake update, se aplicável] → rebuild → push (se houver commits a enviar).
# Tudo em sequência automática, sem voltar ao menu no meio do processo.

set -euo pipefail

NIXOS_DIR="/home/borba/nixos-config"
GIT_BRANCH="m2config"

# attr do flake -> nome real da máquina (usado pra auto-detecção via `hostname`)
declare -A HOST_ATTR_TO_MACHINE=(
  [m2utm]="macutm"
  [dell]="dell1456"
  [macbook2011]="mac2011"
)

# attr do flake -> nome amigável (só pra exibição no menu)
declare -A HOST_ATTR_TO_LABEL=(
  [m2utm]="MacBook M2 - UTM"
  [dell]="Dell Inspiron 1456"
  [macbook2011]="MacBook Pro 13pol (2011)"
)

FLAKE_ATTRS=(m2utm dell macbook2011)

# selecionado em runtime por select_flake_attr()
FLAKE_ATTR=""

# ----- cores (desativa se não for terminal interativo) -----
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'
  C_GREEN='\033[32m'; C_YELLOW='\033[33m'; C_RED='\033[31m'
  C_BLUE='\033[34m'; C_CYAN='\033[36m'; C_MAGENTA='\033[35m'; C_GRAY='\033[90m'
else
  C_RESET=''; C_BOLD=''; C_DIM=''
  C_GREEN=''; C_YELLOW=''; C_RED=''
  C_BLUE=''; C_CYAN=''; C_MAGENTA=''; C_GRAY=''
fi

log()  { echo -e "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; }
ok()   { echo -e "${C_GREEN}✓${C_RESET} $*"; }
warn() { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
err()  { echo -e "${C_RED}✗${C_RESET} $*" >&2; }
step() {
  # step <atual> <total> <descrição>
  echo
  echo -e "${C_MAGENTA}${C_BOLD}[$1/$2]${C_RESET} ${C_BOLD}$3${C_RESET}"
}

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
  read -r -p "$(echo -e "${C_CYAN}?${C_RESET} ${prompt} ${C_DIM}[s/N]${C_RESET} ")" reply
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
  echo -e "${C_CYAN}Hosts disponíveis:${C_RESET}" >&2
  local i=1 attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo -e "  ${C_YELLOW}${i})${C_RESET} ${C_BOLD}${HOST_ATTR_TO_LABEL[$attr]}${C_RESET} ${C_GRAY}(${attr})${C_RESET}" >&2
    i=$((i + 1))
  done
  local choice
  read -r -p "$(echo -e "${C_CYAN}?${C_RESET} Escolha o host [1-${#FLAKE_ATTRS[@]}]: ")" choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#FLAKE_ATTRS[@]}" ]; then
    echo "${FLAKE_ATTRS[$((choice - 1))]}"
    return 0
  fi
  return 1
}

# select_flake_attr [host_arg]
# prioridade: arg explícito > env NIXOS_FLAKE_ATTR > pergunta interativa
# (não assume nenhum host por padrão — sempre pergunta se não vier explícito)
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

  # Sem argumento explícito e sem env var: SEMPRE pergunta.
  # (Antes tentava auto-detectar pelo hostname, mas isso pode acertar o host
  # errado quando o comando é disparado de outra máquina/sessão — melhor
  # perguntar toda vez do que assumir um host padrão.)
  if FLAKE_ATTR="$(prompt_flake_attr)"; then
    return 0
  fi

  err "Nenhum host selecionado."
  exit 1
}

# ----- git helpers -----
#
# O fluxo de git foi dividido em 3 passos independentes, chamados em sequência
# pelas ações principais (build_flake / update_system), SEM voltar ao menu
# entre um passo e outro:
#   1) git_commit_if_dirty  -> commita alterações locais pendentes (se houver)
#   2) git_sync_pull        -> traz o que tiver de novo no remoto
#   3) git_push_if_ahead    -> envia commits locais que ainda não foram (no fim)

git_commit_if_dirty() {
  cd "$NIXOS_DIR"
  if [ -z "$(git status --porcelain)" ]; then
    ok "Árvore de trabalho limpa — nada para commitar."
    return 0
  fi

  warn "Alterações locais não commitadas:"
  git -c color.status=always status --short
  if ! confirm "Commitar essas alterações agora e continuar com o build?"; then
    warn "Continuando com alterações NÃO commitadas (build usará o estado atual do diretório)."
    return 0
  fi

  git add -A
  read -r -p "$(echo -e "${C_CYAN}?${C_RESET} Mensagem do commit ${C_DIM}[lock: update]${C_RESET}: ")" msg
  msg="${msg:-lock: update}"
  git commit -m "$msg"
  ok "Commit criado localmente."
}

git_sync_pull() {
  cd "$NIXOS_DIR"
  log "Puxando alterações do branch ${C_BOLD}${GIT_BRANCH}${C_RESET}..."
  git pull origin "$GIT_BRANCH"
}

git_push_if_ahead() {
  cd "$NIXOS_DIR"
  git fetch origin "$GIT_BRANCH" --quiet 2>/dev/null || true

  local ahead
  ahead="$(git rev-list --count "origin/${GIT_BRANCH}..HEAD" 2>/dev/null || echo 0)"

  if [ "$ahead" -eq 0 ]; then
    ok "Nada para enviar — já sincronizado com origin/${GIT_BRANCH}."
    return 0
  fi

  log "$ahead commit(s) local(is) à frente de origin/${GIT_BRANCH}."
  if confirm "Enviar (push) para ${GIT_BRANCH}?"; then
    git push origin "$GIT_BRANCH"
    ok "Push concluído."
  else
    warn "Push cancelado pelo usuário — alterações continuam só locais."
  fi
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
  cd "$NIXOS_DIR"

  step 1 4 "Verificando alterações locais"
  git_commit_if_dirty

  step 2 4 "Sincronizando com origin/${GIT_BRANCH}"
  git_sync_pull

  step 3 4 "Aplicando rebuild — ${C_CYAN}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_GRAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Rebuild concluído em ${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]} (${FLAKE_ATTR})."

  step 4 4 "Enviando alterações pendentes"
  git_push_if_ahead
}

build_flake_dry() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"

  step 1 2 "Sincronizando com origin/${GIT_BRANCH}"
  git_sync_pull

  step 2 2 "Build de teste (não ativa) — ${C_CYAN}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_GRAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild build --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Build de teste concluído — nada foi ativado. Resultado em ./result"
}

update_system() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"

  step 1 6 "Verificando alterações locais"
  git_commit_if_dirty

  step 2 6 "Sincronizando com origin/${GIT_BRANCH}"
  git_sync_pull

  step 3 6 "Atualizando flake.lock (nix flake update)"
  sudo nix flake update

  step 4 6 "Commitando flake.lock atualizado (se mudou)"
  git_commit_if_dirty

  step 5 6 "Aplicando rebuild — ${C_CYAN}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_GRAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Sistema atualizado em ${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]} (${FLAKE_ATTR})."

  step 6 6 "Enviando alterações pendentes"
  git_push_if_ahead
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
  echo -e "  ${C_YELLOW}1)${C_RESET} Rápido    — remove gerações com mais de 14 dias"
  echo -e "  ${C_RED}2)${C_RESET} Agressivo — remove TODAS as gerações antigas (nix-collect-garbage -d)"
  read -r -p "$(echo -e "${C_CYAN}?${C_RESET} Escolha [1/2]: ")" mode

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
  echo -e "${C_BOLD}${C_CYAN}Hosts configurados no flake:${C_RESET}"
  local attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo -e "  ${C_GREEN}●${C_RESET} ${C_BOLD}${HOST_ATTR_TO_LABEL[$attr]}${C_RESET}  ${C_GRAY}(attr: ${attr}, hostname: ${HOST_ATTR_TO_MACHINE[$attr]})${C_RESET}"
  done
  local detected
  echo
  if detected="$(detect_flake_attr)"; then
    ok "Esta máquina corresponde a: ${C_BOLD}${detected}${C_RESET}"
  else
    warn "Esta máquina ($(hostname -s 2>/dev/null || echo '?')) não corresponde a nenhum host conhecido."
  fi
}

# ----- menu -----

print_banner() {
  local detected
  detected="$(detect_flake_attr 2>/dev/null || echo 'não identificado')"
  echo
  echo -e "${C_CYAN}╭──────────────────────────────────────╮${C_RESET}"
  printf "${C_CYAN}│${C_RESET}  ${C_BOLD}NixOS Manager${C_RESET}%*s${C_CYAN}│${C_RESET}\n" 24 ""
  echo -e "${C_CYAN}│${C_RESET}  ${C_GRAY}esta máquina: ${C_RESET}${C_GREEN}${detected}${C_RESET}$(printf '%*s' $((25 - ${#detected})) '')${C_CYAN}│${C_RESET}"
  echo -e "${C_CYAN}╰──────────────────────────────────────╯${C_RESET}"
  echo -e "  ${C_GRAY}${C_DIM}(build/update sempre perguntam o host — nada é assumido)${C_RESET}"
}

show_menu() {
  print_banner
  echo
  echo -e "  ${C_YELLOW}${C_BOLD}1)${C_RESET} Build sem flake     ${C_GRAY}(nixos-rebuild switch)${C_RESET}"
  echo -e "  ${C_YELLOW}${C_BOLD}2)${C_RESET} Build com flake     ${C_GRAY}(commit → pull → rebuild → push)${C_RESET}"
  echo -e "  ${C_YELLOW}${C_BOLD}3)${C_RESET} Limpar cache        ${C_GRAY}(nix-collect-garbage + optimise)${C_RESET}"
  echo -e "  ${C_YELLOW}${C_BOLD}4)${C_RESET} Atualizar sistema   ${C_GRAY}(commit → pull → flake update → rebuild → push)${C_RESET}"
  echo -e "  ${C_YELLOW}${C_BOLD}5)${C_RESET} Build de teste      ${C_GRAY}(nixos-rebuild build, não ativa nada)${C_RESET}"
  echo -e "  ${C_RED}${C_BOLD}6)${C_RESET} Rollback            ${C_GRAY}(voltar para geração anterior)${C_RESET}"
  echo -e "  ${C_YELLOW}${C_BOLD}7)${C_RESET} Verificar flake     ${C_GRAY}(nix flake check)${C_RESET}"
  echo -e "  ${C_BLUE}${C_BOLD}8)${C_RESET} Listar hosts        ${C_GRAY}(mostra hosts do flake e detecção atual)${C_RESET}"
  echo -e "  ${C_BOLD}0)${C_RESET} Sair"
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
    read -r -p "$(echo -e "${C_CYAN}?${C_RESET} Escolha uma opção: ")" choice
    run_choice "$choice" || true
  done
}

main "$@"
