#!/usr/bin/env bash
# devshell.sh — Interactive launcher for the Nix devShells defined in devshells.nix
#
# Usage:
#   ./devshell.sh              # interactive menu
#   ./devshell.sh rust         # jump straight into a known shell
#   ./devshell.sh --list       # just list available shells and exit
#
# Colors follow the Catppuccin Mocha palette (mauve accent), matching the
# i3/ly theme used across macutm, dell1456 and macbook2011.

set -euo pipefail

# ---------------------------------------------------------------------------
# Catppuccin Mocha palette (24-bit ANSI)
# ---------------------------------------------------------------------------
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

MAUVE='\033[38;2;203;166;247m'    # accent
BLUE='\033[38;2;137;180;250m'
GREEN='\033[38;2;166;227;161m'
YELLOW='\033[38;2;249;226;175m'
PEACH='\033[38;2;250;179;135m'
RED='\033[38;2;243;139;168m'
TEAL='\033[38;2;148;226;213m'
TEXT='\033[38;2;205;214;244m'
SUBTEXT='\033[38;2;166;173;200m'
SURFACE='\033[38;2;69;71;90m'

# ---------------------------------------------------------------------------
# Shell catalog: name | emoji | short description
# Keep this in sync with devshells.nix
# ---------------------------------------------------------------------------
SHELL_NAMES=(rust rust-nightly go python lua nix-dev secrets postgresql mariadb sqlite databases devops default)
SHELL_EMOJI=("🦀" "🦀" "🐹" "🐍" "🌙" "❄️ " "🔐" "🐘" "🐬" "💾" "🗄️ " "🚀" "💻")
SHELL_DESC=(
  "Rust stable (rustc, cargo, clippy, rust-analyzer + DB clients)"
  "Rust nightly (fenix complete toolchain + DB clients)"
  "Go 1.25 (gopls, delve, golangci-lint, air + DB clients)"
  "Python 3.12 (uv, ruff, mypy, python-lsp-server)"
  "Lua 5.4 + LuaJIT (stylua, selene, luarocks)"
  "Nix tooling (nixd, nil, statix, deadnix, alejandra)"
  "SOPS + age secrets management"
  "PostgreSQL (psql, pgcli, pgformatter, usql)"
  "MariaDB (mysql, mycli, usql)"
  "SQLite (sqlite3, litecli, sqlitebrowser, usql)"
  "All databases combined"
  "DevOps (kubectl, helm, terraform, ansible, podman)"
  "Default (rust + go + node)"
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
die() {
  printf "${RED}${BOLD}✗ Erro:${RESET} ${RED}%s${RESET}\n" "$1" >&2
  exit 1
}

info() {
  printf "${BLUE}%s${RESET}\n" "$1"
}

ok() {
  printf "${GREEN}✓ %s${RESET}\n" "$1"
}

print_header() {
  printf "\n${MAUVE}${BOLD}╭──────────────────────────────────────────────────╮${RESET}\n"
  printf "${MAUVE}${BOLD}│${RESET}   ${TEAL}${BOLD}❄  nixos-config devshell launcher${RESET}${MAUVE}${BOLD}                │${RESET}\n"
  printf "${MAUVE}${BOLD}╰──────────────────────────────────────────────────╯${RESET}\n\n"
}

print_menu() {
  local i
  for i in "${!SHELL_NAMES[@]}"; do
    printf "  ${PEACH}${BOLD}%2d${RESET}  ${TEXT}%s${RESET} ${MAUVE}%-14s${RESET} ${SUBTEXT}%s${RESET}\n" \
      "$((i + 1))" "${SHELL_EMOJI[$i]}" "${SHELL_NAMES[$i]}" "${SHELL_DESC[$i]}"
  done
  printf "\n  ${SURFACE}${BOLD} 0${RESET}  ${SUBTEXT}sair / cancelar${RESET}\n\n"
}

index_of_name() {
  local target="$1" i
  for i in "${!SHELL_NAMES[@]}"; do
    [[ "${SHELL_NAMES[$i]}" == "$target" ]] && { echo "$i"; return 0; }
  done
  return 1
}

check_nix() {
  command -v nix >/dev/null 2>&1 || die "comando 'nix' não encontrado no PATH."
  [[ -f "flake.nix" ]] || die "flake.nix não encontrado no diretório atual. Rode este script na raiz de ~/nixos-config."
}

launch_shell() {
  local idx="$1"
  local name="${SHELL_NAMES[$idx]}"
  local emoji="${SHELL_EMOJI[$idx]}"

  printf "\n${GREEN}${BOLD}▶ Iniciando devShell:${RESET} ${MAUVE}${BOLD}%s${RESET} %s\n" "$name" "$emoji"
  printf "${SUBTEXT}  comando: nix develop .#%s${RESET}\n\n" "$name"

  exec nix develop ".#${name}"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
main() {
  check_nix

  # Direct shell name passed as argument
  if [[ "${1:-}" != "" && "${1:-}" != "--list" && "${1:-}" != "-l" ]]; then
    local idx
    if idx="$(index_of_name "$1")"; then
      print_header
      launch_shell "$idx"
    else
      die "devShell '$1' não existe. Use --list para ver as opções."
    fi
  fi

  print_header

  if [[ "${1:-}" == "--list" || "${1:-}" == "-l" ]]; then
    print_menu
    exit 0
  fi

  # Prefer fzf for a nicer picker, if available
  if command -v fzf >/dev/null 2>&1; then
    local chosen
    chosen=$(
      for i in "${!SHELL_NAMES[@]}"; do
        printf "%s\t%s  %-14s %s\n" "${SHELL_NAMES[$i]}" "${SHELL_EMOJI[$i]}" "${SHELL_NAMES[$i]}" "${SHELL_DESC[$i]}"
      done | fzf --with-nth=2.. --delimiter='\t' \
                 --prompt="devshell> " \
                 --header="Selecione um devShell (Esc para cancelar)" \
                 --height=~60% --border --reverse \
                 --color="bg+:#313244,fg+:#cdd6f4,hl:#cba6f7,hl+:#cba6f7,border:#cba6f7,prompt:#f5c2e7" \
      | cut -f1
    )
    [[ -z "$chosen" ]] && { info "Cancelado."; exit 0; }
    local idx
    idx="$(index_of_name "$chosen")"
    launch_shell "$idx"
  fi

  # Fallback: numbered menu
  print_menu
  local choice
  read -rp "$(printf "${BOLD}${TEXT}Escolha um devShell [0-%d]: ${RESET}" "${#SHELL_NAMES[@]}")" choice

  [[ "$choice" == "0" || -z "$choice" ]] && { info "Cancelado."; exit 0; }
  [[ "$choice" =~ ^[0-9]+$ ]] || die "entrada inválida: '$choice'."
  (( choice >= 1 && choice <= ${#SHELL_NAMES[@]} )) || die "opção fora do intervalo: '$choice'."

  launch_shell "$((choice - 1))"
}

main "$@"
