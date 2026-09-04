#!/usr/bin/env bash
# tmux-devshell.sh
#
# Launcher que permite escolher um "profile" (combinação pré-definida de
# devshells Nix) ou montar um combo customizado, e abre uma sessão tmux
# com uma window por devshell, cada uma já rodando `nix develop`.
#
# Pensado pra ser instalado como comando (~/.local/bin/tmux-devshell, via
# home/modules/cli-and-terminal.nix) e rodado de DENTRO do projeto em
# $HOME/prj/<algo> — não precisa estar na raiz do nixos-config. Os
# devshells continuam vindo do nixos-config (NIXOS_CONFIG_DIR), mas o
# `cwd` de cada window é o projeto de onde você chamou o comando
# (PROJECT_DIR), não o repo.
#
# Uso:
#   tmux-devshell                # menu interativo, a partir do projeto atual
#   tmux-devshell --clean        # mata sessão existente antes de criar
#   tmux-devshell go+maria       # pula o menu, usa o profile direto
#   tmux-devshell --destroy      # mata sessão(ões) de devshell do projeto atual, sem recriar
#   tmux-devshell --destroy --gc # idem, e ainda roda `nix store gc` (pede confirmação)
#
set -euo pipefail

# --- Catppuccin Mocha palette -------------------------------------------
C_MAUVE='\033[38;2;203;166;247m'
C_SKY='\033[38;2;137;220;235m'
C_GREEN='\033[38;2;166;227;161m'
C_YELLOW='\033[38;2;249;226;175m'
C_PEACH='\033[38;2;250;179;135m'
C_RED='\033[38;2;243;139;168m'
C_TEAL='\033[38;2;148;226;213m'
C_TEXT='\033[38;2;205;214;244m'
C_OVERLAY='\033[38;2;108;112;134m'
C_RESET='\033[0m'

# --- Config ---------------------------------------------------------------
# Onde fica o nixos-config (pra achar devshells/) — fixo, não depende de
# onde o comando foi chamado. Mesmo caminho já usado em nixos-manager.sh.
NIXOS_CONFIG_DIR="${NIXOS_CONFIG_DIR:-$HOME/nixos-config}"
DEVSHELLS_DIR="${DEVSHELLS_DIR:-$NIXOS_CONFIG_DIR/devshells}"

# Onde você está trabalhando — vira o cwd real de cada window/pane.
# Default: diretório de onde o comando foi chamado (ex: $HOME/prj/minha-api).
PROJECT_DIR="${PROJECT_DIR:-$(pwd)}"

SESSION_PREFIX="${SESSION_PREFIX:-dev}"
CLEAN=false
DESTROY=false
GC=false

# Profiles pré-definidos: "nome" => "devshell1 devshell2 ..."
# Edite/adicione livremente conforme suas pastas em devshells/
declare -A PROFILES=(
  ["go+maria"]="go mariadb"
  ["go+postgres"]="go postgresql"
  ["rust+postgres"]="rust postgresql"
  ["rust+maria"]="rust mariadb"
  ["lua+sqlite"]="lua sqlite"
  ["python+mongo"]="python mongodb"
  ["fullstack"]="go rust postgresql mariadb"
)

# --- Args -------------------------------------------------------------
PROFILE_ARG=""
for arg in "$@"; do
  case "$arg" in
    --clean) CLEAN=true ;;
    --destroy) DESTROY=true ;;
    --gc) GC=true ;;
    *) PROFILE_ARG="$arg" ;;
  esac
done

# --- Destroy: mata sessão(ões) de devshell do projeto atual, sem recriar --
# Diferente do --clean (mata e recria na hora), --destroy só limpa. Não dá
# pra reconstruir o nome de uma sessão "custom-X-Y" a partir de um profile
# arbitrário, então lista as sessões do projeto atual (prefixo determinístico
# dev-<projeto>-) e deixa escolher qual(is) matar.
if [[ "$DESTROY" == true ]]; then
  prefix="${SESSION_PREFIX}-$(basename "$PROJECT_DIR")-"
  mapfile -t matches < <(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -F "$prefix" || true)

  if [[ ${#matches[@]} -eq 0 ]]; then
    echo -e "${C_YELLOW}Nenhuma sessão de devshell encontrada para ${PROJECT_DIR} (prefixo ${prefix}).${C_RESET}"
    exit 0
  fi

  TARGETS=()
  if [[ ${#matches[@]} -eq 1 ]]; then
    TARGETS=("${matches[0]}")
  elif command -v fzf &>/dev/null; then
    mapfile -t TARGETS < <(printf '%s\n' "${matches[@]}" | fzf --multi \
      --prompt="Sessão(ões) p/ destruir [TAB p/ multi, ENTER confirma] > " \
      --height=40% --border)
  else
    echo -e "${C_YELLOW}fzf não encontrado, usando fallback numerado${C_RESET}" >&2
    i=1
    for m in "${matches[@]}"; do
      printf "${C_TEAL}%2d)${C_TEXT} %s${C_RESET}\n" "$i" "$m" >&2
      ((i++))
    done
    read -rp $'\n'"Numeros separados por espaco (ex: 1 3), ou 'all': " -a nums
    if [[ "${nums[0]:-}" == "all" ]]; then
      TARGETS=("${matches[@]}")
    else
      for n in "${nums[@]}"; do
        idx=$((n-1))
        [[ $idx -ge 0 && $idx -lt ${#matches[@]} ]] && TARGETS+=("${matches[$idx]}")
      done
    fi
  fi

  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo -e "${C_RED}Nenhuma sessão selecionada.${C_RESET}"
    exit 0
  fi

  for t in "${TARGETS[@]}"; do
    echo -e "${C_YELLOW}Matando sessão '${t}'...${C_RESET}"
    tmux kill-session -t "$t" 2>/dev/null || true
  done

  if [[ "$GC" == true ]]; then
    echo -e "${C_PEACH}Isso roda GC no Nix store inteiro (não só nos pacotes deste devshell) — outros geracões/paths não referenciados também são removidos.${C_RESET}"
    read -rp "Confirma o nix store gc? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      nix store gc
    else
      echo -e "${C_OVERLAY}GC cancelado.${C_RESET}"
    fi
  else
    echo -e "${C_OVERLAY}Sessão(ões) encerrada(s). Os pacotes do devshell continuam no Nix store até um GC (rode com --destroy --gc, ou 'nix store gc' manualmente).${C_RESET}"
  fi

  exit 0
fi

if [[ ! -d "$DEVSHELLS_DIR" ]]; then
  echo -e "${C_RED}Erro: diretório de devshells não encontrado: ${DEVSHELLS_DIR}${C_RESET}"
  echo -e "${C_OVERLAY}Confira se o nixos-config está clonado em ${NIXOS_CONFIG_DIR}, ou defina NIXOS_CONFIG_DIR.${C_RESET}"
  exit 1
fi

mapfile -t AVAILABLE_SHELLS < <(find "$DEVSHELLS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)

if [[ ${#AVAILABLE_SHELLS[@]} -eq 0 ]]; then
  echo -e "${C_RED}Nenhum devshell encontrado em ${DEVSHELLS_DIR}${C_RESET}"
  exit 1
fi

echo -e "${C_MAUVE}=== Nix Devshell Tmux Launcher ===${C_RESET}"

SELECTED=()
PROFILE_NAME=""

pick_profile_menu() {
  local names=("${!PROFILES[@]}" "custom")
  IFS=$'\n' names=($(sort <<<"${names[*]}")); unset IFS

  if command -v fzf &>/dev/null; then
    # Mapa profile→devshells num arquivo temporário: o preview do fzf roda no
    # $SHELL do usuário (zsh) e NÃO herda o declare -A PROFILES do bash.
    # ${PROFILES[custom]} no zsh vira aritmética → "bad math expression".
    local profile_map
    profile_map=$(mktemp)
    for k in "${!PROFILES[@]}"; do
      printf '%s\t%s\n' "$k" "${PROFILES[$k]}"
    done >"$profile_map"
    printf '%s\t%s\n' "custom" "(seleção manual de devshells)" >>"$profile_map"

    local choice
    choice=$(printf '%s\n' "${names[@]}" | fzf \
      --prompt="Escolha um profile [ENTER confirma] > " \
      --height=40% --border \
      --preview "awk -F'\t' -v p={} '\$1==p {print \"Devshells: \" \$2}' '$profile_map'" \
      --preview-window=up:2)
    rm -f "$profile_map"
    echo "$choice"
  else
    echo -e "${C_YELLOW}fzf não encontrado, usando fallback numerado${C_RESET}" >&2
    local i=1
    for n in "${names[@]}"; do
      if [[ "$n" == "custom" ]]; then
        printf "${C_TEAL}%2d)${C_TEXT} %s ${C_OVERLAY}(selecionar manualmente)${C_RESET}\n" "$i" "$n" >&2
      else
        printf "${C_TEAL}%2d)${C_TEXT} %-16s ${C_OVERLAY}%s${C_RESET}\n" "$i" "$n" "${PROFILES[$n]}" >&2
      fi
      ((i++))
    done
    read -rp $'\n'"Numero do profile: " num
    echo "${names[$((num-1))]}"
  fi
}

pick_custom_shells() {
  local out=()
  if command -v fzf &>/dev/null; then
    mapfile -t out < <(printf '%s\n' "${AVAILABLE_SHELLS[@]}" | fzf --multi \
      --prompt="Selecione devshell(s) [TAB p/ multi, ENTER confirma] > " \
      --height=40% --border)
  else
    echo -e "${C_YELLOW}fzf não encontrado, usando fallback numerado${C_RESET}" >&2
    local i
    for i in "${!AVAILABLE_SHELLS[@]}"; do
      printf "${C_TEAL}%2d)${C_TEXT} %s${C_RESET}\n" "$((i+1))" "${AVAILABLE_SHELLS[$i]}" >&2
    done
    read -rp $'\n'"Numeros separados por espaco (ex: 1 3): " -a nums
    for n in "${nums[@]}"; do
      local idx=$((n-1))
      [[ $idx -ge 0 && $idx -lt ${#AVAILABLE_SHELLS[@]} ]] && out+=("${AVAILABLE_SHELLS[$idx]}")
    done
  fi
  printf '%s\n' "${out[@]}"
}

# --- Resolve seleção ----------------------------------------------------
if [[ -n "$PROFILE_ARG" && -n "${PROFILES[$PROFILE_ARG]+x}" ]]; then
  PROFILE_NAME="$PROFILE_ARG"
  read -ra SELECTED <<< "${PROFILES[$PROFILE_NAME]}"
else
  PROFILE_NAME=$(pick_profile_menu)
  if [[ -z "$PROFILE_NAME" ]]; then
    echo -e "${C_RED}Nenhuma opção selecionada. Abortando.${C_RESET}"
    exit 1
  fi

  if [[ "$PROFILE_NAME" == "custom" ]]; then
    mapfile -t SELECTED < <(pick_custom_shells)
    PROFILE_NAME="custom-$(IFS=-; echo "${SELECTED[*]}")"
  else
    read -ra SELECTED <<< "${PROFILES[$PROFILE_NAME]}"
  fi
fi

if [[ ${#SELECTED[@]} -eq 0 ]]; then
  echo -e "${C_RED}Nenhum devshell selecionado. Abortando.${C_RESET}"
  exit 1
fi

# valida que cada devshell selecionado existe de fato
for s in "${SELECTED[@]}"; do
  if [[ ! -d "$DEVSHELLS_DIR/$s" ]]; then
    echo -e "${C_RED}Aviso: devshell '${s}' não existe em ${DEVSHELLS_DIR}, pulando.${C_RESET}"
  fi
done

echo -e "${C_GREEN}Projeto:${C_RESET} ${PROJECT_DIR}"
echo -e "${C_GREEN}Profile:${C_RESET} ${PROFILE_NAME}"
echo -e "${C_GREEN}Devshells:${C_RESET} ${SELECTED[*]} ${C_OVERLAY}(de ${DEVSHELLS_DIR})${C_RESET}"

SESSION_NAME="${SESSION_PREFIX}-$(basename "$PROJECT_DIR")-${PROFILE_NAME}"

# --- Tmux session ---------------------------------------------------------
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  if [[ "$CLEAN" == true ]]; then
    echo -e "${C_YELLOW}Matando sessão existente '${SESSION_NAME}'...${C_RESET}"
    tmux kill-session -t "$SESSION_NAME"
  else
    echo -e "${C_YELLOW}Sessão '${SESSION_NAME}' já existe. Anexando...${C_RESET}"
    echo -e "${C_OVERLAY}(se as ferramentas do devshell não aparecerem dentro da sessão, o 'nix develop' dessa window já saiu antes — rode com --clean pra recriar)${C_RESET}"
    tmux attach -t "$SESSION_NAME"
    exit 0
  fi
fi

FIRST="${SELECTED[0]}"
tmux new-session -d -s "$SESSION_NAME" -n "$FIRST" \
  "cd '$PROJECT_DIR' && nix develop '$DEVSHELLS_DIR/$FIRST'; exec \$SHELL"

for shell in "${SELECTED[@]:1}"; do
  tmux new-window -t "$SESSION_NAME" -n "$shell" \
    "cd '$PROJECT_DIR' && nix develop '$DEVSHELLS_DIR/$shell'; exec \$SHELL"
done

tmux select-window -t "${SESSION_NAME}:1"

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$SESSION_NAME"
else
  tmux attach -t "$SESSION_NAME"
fi
