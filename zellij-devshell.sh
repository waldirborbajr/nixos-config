#!/usr/bin/env bash
# zellij-devshell.sh
#
# Mesmo launcher do tmux-devshell.sh (escolher um "profile" pré-definido
# de devshells Nix, ou montar um combo customizado), só que abrindo uma
# sessão Zellij em vez de tmux — uma tab por devshell, cada uma já
# rodando `nix develop`.
#
# Diferença de mecanismo (não de comportamento visível): tmux cria a
# sessão detached e vai adicionando window por window via
# `tmux new-window`; Zellij não tem um "-d" equivalente pra isso, então
# a lista de devshells vira um layout KDL gerado na hora (um `tab` por
# devshell) e a sessão nasce já com todas as tabs de uma vez via
# `zellij --new-session-with-layout`.
#
# Uso:
#   ./zellij-devshell.sh              # menu interativo
#   ./zellij-devshell.sh --clean      # mata sessão existente antes de criar
#   ./zellij-devshell.sh go+maria     # pula o menu, usa o profile direto
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
# Raiz onde fica a pasta devshells/ (ex: ~/nixos-config)
REPO_ROOT="${REPO_ROOT:-$(pwd)}"
DEVSHELLS_DIR="${DEVSHELLS_DIR:-$REPO_ROOT/devshells}"
SESSION_PREFIX="${SESSION_PREFIX:-dev}"
CLEAN=false

# Profiles pré-definidos: "nome" => "devshell1 devshell2 ..."
# Mantido idêntico ao tmux-devshell.sh de propósito — edite os dois juntos
# se for adicionar/remover profile, pra não desalinhar as duas ferramentas.
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
    *) PROFILE_ARG="$arg" ;;
  esac
done

if ! command -v zellij &>/dev/null; then
  echo -e "${C_RED}Erro: zellij não encontrado no PATH.${C_RESET}"
  echo -e "${C_OVERLAY}Está em home/modules/cli-and-terminal.nix — confirme que o host importa esse módulo.${C_RESET}"
  exit 1
fi

if [[ ! -d "$DEVSHELLS_DIR" ]]; then
  echo -e "${C_RED}Erro: diretório de devshells não encontrado: ${DEVSHELLS_DIR}${C_RESET}"
  echo -e "${C_OVERLAY}Defina REPO_ROOT ou rode este script na raiz do nixos-config.${C_RESET}"
  exit 1
fi

mapfile -t AVAILABLE_SHELLS < <(find "$DEVSHELLS_DIR" -maxdepth 1 -mindepth 1 -type d -exec basename {} \; | sort)

if [[ ${#AVAILABLE_SHELLS[@]} -eq 0 ]]; then
  echo -e "${C_RED}Nenhum devshell encontrado em ${DEVSHELLS_DIR}${C_RESET}"
  exit 1
fi

echo -e "${C_MAUVE}=== Nix Devshell Zellij Launcher ===${C_RESET}"

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

echo -e "${C_GREEN}Profile:${C_RESET} ${PROFILE_NAME}"
echo -e "${C_GREEN}Devshells:${C_RESET} ${SELECTED[*]}"

SESSION_NAME="${SESSION_PREFIX}-${PROFILE_NAME}"

# --- Sessão já existe? ---------------------------------------------------
# `zellij list-sessions` imprime "nome (detalhes...)" por linha; pegar só
# a 1a coluna é mais resiliente a mudanças de formatação entre versões do
# que tentar casar a linha inteira.
session_exists() {
  zellij list-sessions --no-formatting 2>/dev/null | awk '{print $1}' | grep -qx "$SESSION_NAME"
}

if session_exists; then
  if [[ "$CLEAN" == true ]]; then
    echo -e "${C_YELLOW}Matando sessão existente '${SESSION_NAME}'...${C_RESET}"
    zellij kill-session "$SESSION_NAME"
  else
    echo -e "${C_YELLOW}Sessão '${SESSION_NAME}' já existe. Anexando...${C_RESET}"
    if [[ -n "${ZELLIJ:-}" ]]; then
      echo -e "${C_OVERLAY}(você já está dentro de uma sessão Zellij — nesting não é bem suportado; considere sair primeiro com Ctrl-o d)${C_RESET}"
    fi
    exec zellij attach "$SESSION_NAME"
  fi
fi

# --- Gera o layout KDL: uma tab por devshell, primeira tab focada -------
# `default_tab_template` reproduz o que o layout `default.kdl` do próprio
# Zellij faz de fábrica (tab-bar em cima, status-bar embaixo com os
# atalhos). Como aqui é um layout escrito na mão, sem isso as tabs vêm
# "nuas" — foi o que sumiu quando o layout gerado tinha só os `pane`.
LAYOUT_FILE=$(mktemp --suffix=.kdl)
trap 'rm -f "$LAYOUT_FILE"' EXIT

{
  cat <<'HEADER'
layout {
    default_tab_template {
        pane size=1 borderless=true {
            plugin location="zellij:tab-bar"
        }
        children
        pane size=2 borderless=true {
            plugin location="zellij:status-bar"
        }
    }
HEADER
  for i in "${!SELECTED[@]}"; do
    shell="${SELECTED[$i]}"
    focus_attr=""
    [[ "$i" -eq 0 ]] && focus_attr=' focus=true'
    cat <<EOF
    tab name="$shell"$focus_attr {
        pane command="bash" cwd="$REPO_ROOT" {
            args "-c" "cd '$REPO_ROOT' && nix develop ./devshells/$shell; exec \$SHELL"
        }
    }
EOF
  done
  echo "}"
} > "$LAYOUT_FILE"

exec zellij --new-session-with-layout "$LAYOUT_FILE" --session "$SESSION_NAME"
