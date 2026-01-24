# ==========================================
# NixOS Infra Makefile (Borba - FINAL, NO-TABS)
# Fixes forever: "missing separator" / "bad recipe lines"
# Strategy: Make only generates + runs a Bash script.
# ==========================================

.RECIPEPREFIX := |
.DEFAULT_GOAL := help

BASH := /run/current-system/sw/bin/bash
SCRIPT := ./.nixosctl

NIXOS_CONFIG ?= $(if $(wildcard $(CURDIR)/flake.nix),$(CURDIR),$(HOME)/nixos-config)

HOST ?=
IMPURE ?=
DEVOPS ?=
QEMU ?=

AUTO_UPDATE_FLAKE ?= 0
AUTO_GIT_COMMIT ?= 1
GIT_COMMIT_MSG ?= chore: auto-commit before rebuild
GIT_PUSH ?=
DEBUG_LOG ?= /tmp/nixos-build-debug.log

.PHONY: help gen doctor hosts flake-show flake-check update-flake fmt current-system list-generations \
        build switch dry-build dry-switch build-debug rollback gc gc-hard clean

help:
| echo "NixOS Infra (flakes) — FINAL (NO-TABS Makefile)"
| echo ""
| echo "Run:"
| echo "  make doctor"
| echo "  make hosts"
| echo "  make switch HOST=macbook [DEVOPS=1] [QEMU=1] [IMPURE=1]"
| echo ""
| echo "Options:"
| echo "  NIXOS_CONFIG=/path/to/nixos-config (default: ./ if flake.nix exists else ~/nixos-config)"
| echo "  AUTO_UPDATE_FLAKE=1 (default 0)"
| echo "  AUTO_GIT_COMMIT=0  (default 1)"
| echo "  GIT_PUSH=1         (default 0)"
| echo ""

gen:
| cat > "$(SCRIPT)" <<'EOF'
#! /run/current-system/sw/bin/bash
set -euo pipefail

NIXOS_CONFIG="${NIXOS_CONFIG:-$HOME/nixos-config}"

HOST="${HOST:-}"
IMPURE="${IMPURE:-}"
DEVOPS="${DEVOPS:-}"
QEMU="${QEMU:-}"

AUTO_UPDATE_FLAKE="${AUTO_UPDATE_FLAKE:-0}"
AUTO_GIT_COMMIT="${AUTO_GIT_COMMIT:-1}"
GIT_COMMIT_MSG="${GIT_COMMIT_MSG:-chore: auto-commit before rebuild}"
GIT_PUSH="${GIT_PUSH:-}"
DEBUG_LOG="${DEBUG_LOG:-/tmp/nixos-build-debug.log}"

SUDO="/run/wrappers/bin/sudo"
NIX="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

die(){ echo "ERROR: $*" >&2; exit 1; }

preflight_base(){
  command -v nix >/dev/null 2>&1 || die "nix not found"
  command -v nixos-rebuild >/dev/null 2>&1 || die "nixos-rebuild not found"
  [[ -x "$SUDO" ]] || die "sudo wrapper not found at $SUDO"
  [[ -f "$NIXOS_CONFIG/flake.nix" ]] || die "flake.nix not found in: $NIXOS_CONFIG"
}

preflight_host(){
  [[ -n "$HOST" ]] || die "HOST is required. Example: make switch HOST=macbook"
}

show_flags(){
  echo "Repo:  $NIXOS_CONFIG"
  echo "Flags: HOST=${HOST:-<none>} IMPURE=$IMPURE DEVOPS=$DEVOPS QEMU=$QEMU"
}

require_flake_host(){
  echo "Validating host '$HOST'..."
  if $NIX eval --raw "$NIXOS_CONFIG#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" >/dev/null; then
    echo "OK: host exists."
  else
    echo ""
    echo "Nix evaluation failed. Real error:"
    echo "----------------------------------------"
    $NIX eval --raw "$NIXOS_CONFIG#nixosConfigurations.$HOST.config.system.build.toplevel.drvPath" || true
    echo "----------------------------------------"
    exit 1
  fi
}

maybe_update_flake(){
  if [[ "$AUTO_UPDATE_FLAKE" == "1" ]]; then
    echo "AUTO_UPDATE_FLAKE=1 -> nix flake update"
    (cd "$NIXOS_CONFIG" && $NIX flake update)
  else
    echo "AUTO_UPDATE_FLAKE=0 -> skipping flake update"
  fi
}

maybe_git_commit(){
  if [[ "$AUTO_GIT_COMMIT" != "1" ]]; then
    echo "AUTO_GIT_COMMIT=0 -> skipping auto-commit"
    return 0
  fi
  command -v git >/dev/null 2>&1 || { echo "git not found -> skipping"; return 0; }
  if [[ -n "$(git -C "$NIXOS_CONFIG" status --porcelain)" ]]; then
    echo "Git changes detected -> add/commit..."
    git -C "$NIXOS_CONFIG" add .
    git -C "$NIXOS_CONFIG" commit -m "$GIT_COMMIT_MSG" || true
    [[ "$GIT_PUSH" == "1" ]] && git -C "$NIXOS_CONFIG" push
  else
    echo "No git changes detected."
  fi
}

print_cmd(){
  local action="$1"; shift || true
  local extra="${*:-}"
  echo ">>> ${DEVOPS:+DEVOPS=1 }${QEMU:+QEMU=1 }env $SUDO nixos-rebuild $action --flake $NIXOS_CONFIG#$HOST ${IMPURE:+--impure }$extra"
}

run_rebuild(){
  local action="$1"; shift || true
  local extra=("$@")
  local envs=()
  [[ -n "$DEVOPS" ]] && envs+=( "DEVOPS=1" )
  [[ -n "$QEMU"  ]] && envs+=( "QEMU=1" )

  if [[ "${#extra[@]}" -gt 0 ]]; then
    env "${envs[@]}" $SUDO nixos-rebuild "$action" --flake "$NIXOS_CONFIG#$HOST" ${IMPURE:+--impure} "${extra[@]}"
  else
    env "${envs[@]}" $SUDO nixos-rebuild "$action" --flake "$NIXOS_CONFIG#$HOST" ${IMPURE:+--impure}
  fi
}

current_system(){
  echo "Current system: $(readlink -f /run/current-system)"
  echo "Profile:        $(readlink -f /nix/var/nix/profiles/system)"
}

list_generations(){
  echo ""
  $SUDO nix-env -p /nix/var/nix/profiles/system --list-generations | tail -n 60
}

cmd="${1:-}"
case "$cmd" in
  doctor)
    preflight_base; show_flags; echo "OK: repo + tools present";;
  hosts)
    preflight_base
    $NIX flake show "$NIXOS_CONFIG" 2>/dev/null | sed -n '/nixosConfigurations/,$p' | sed -n '1,220p' || true;;
  flake-show)
    preflight_base; (cd "$NIXOS_CONFIG" && $NIX flake show);;
  flake-check)
    preflight_base; (cd "$NIXOS_CONFIG" && $NIX flake check);;
  update-flake)
    preflight_base; (cd "$NIXOS_CONFIG" && $NIX flake update);;
  fmt)
    preflight_base; (cd "$NIXOS_CONFIG" && (nix fmt || nix run nixpkgs#nixpkgs-fmt -- .));;
  current-system)
    preflight_base; current_system;;
  list-generations)
    preflight_base; list_generations;;
  dry-build)
    preflight_base; preflight_host; require_flake_host; print_cmd build --dry-run; run_rebuild build --dry-run;;
  dry-switch)
    preflight_base; preflight_host; require_flake_host; print_cmd switch --dry-run; run_rebuild switch --dry-run;;
  build)
    preflight_base; preflight_host; require_flake_host; maybe_update_flake; maybe_git_commit
    echo "Before:"; current_system
    print_cmd build; run_rebuild build
    echo "After:"; current_system; list_generations;;
  switch)
    preflight_base; preflight_host; require_flake_host; maybe_update_flake; maybe_git_commit
    echo "Before:"; current_system
    print_cmd switch; run_rebuild switch
    echo "After:"; current_system; list_generations;;
  build-debug)
    preflight_base; preflight_host; require_flake_host; maybe_update_flake; maybe_git_commit
    print_cmd switch --verbose --show-trace
    run_rebuild switch --verbose --show-trace | tee "$DEBUG_LOG"
    echo "Saved log: $DEBUG_LOG";;
  rollback)
    preflight_base; $SUDO nixos-rebuild switch --rollback; list_generations;;
  gc)
    preflight_base; $SUDO nix-collect-garbage;;
  gc-hard)
    preflight_base; $SUDO nix-collect-garbage -d --delete-older-than 1d;;
  *)
    echo "Unknown command: $cmd" >&2
    exit 1;;
esac
EOF
| chmod +x "$(SCRIPT)"
| echo "Generated $(SCRIPT)"

doctor: gen
| "$(BASH)" "$(SCRIPT)" doctor

hosts: gen
| "$(BASH)" "$(SCRIPT)" hosts

flake-show: gen
| "$(BASH)" "$(SCRIPT)" flake-show

flake-check: gen
| "$(BASH)" "$(SCRIPT)" flake-check

update-flake: gen
| "$(BASH)" "$(SCRIPT)" update-flake

fmt: gen
| "$(BASH)" "$(SCRIPT)" fmt

current-system: gen
| "$(BASH)" "$(SCRIPT)" current-system

list-generations: gen
| "$(BASH)" "$(SCRIPT)" list-generations

dry-build: gen
| "$(BASH)" "$(SCRIPT)" dry-build

dry-switch: gen
| "$(BASH)" "$(SCRIPT)" dry-switch

build: gen
| "$(BASH)" "$(SCRIPT)" build

switch: gen
| "$(BASH)" "$(SCRIPT)" switch

build-debug: gen
| "$(BASH)" "$(SCRIPT)" build-debug

rollback: gen
| "$(BASH)" "$(SCRIPT)" rollback

gc: gen
| "$(BASH)" "$(SCRIPT)" gc

gc-hard: gen
| "$(BASH)" "$(SCRIPT)" gc-hard

clean:
| rm -f "$(SCRIPT)"
| echo "Removed $(SCRIPT)"