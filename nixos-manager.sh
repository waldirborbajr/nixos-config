#!/usr/bin/env bash
#
# nixos-manager.sh — manage NixOS rebuilds, cache, and updates
#
# Initial setup on a fresh machine:
#   sudo mv /etc/nixos /etc/nixos.bak   # backup
#   sudo ln -s /home/borba/nixos-config /etc/nixos
# (also available as menu option 0 / `setup`)
#
# Usage:
#   ./nixos-manager.sh                    # opens the interactive menu
#   ./nixos-manager.sh <option>            # runs directly: legacy | flake | clean | update
#   ./nixos-manager.sh <option> <host>     # runs directly on a specific host: flake dell
#   NIXOS_FLAKE_ATTR=dell ./nixos-manager.sh flake   # force the host via env var
#
# Requirements: git repo at /etc/nixos with the flake configured.
#
# Known hosts (defined in flake.nix -> nixosConfigurations):
#   m2utm       (macutm)    aarch64-linux
#   dell        (dell1456)  x86_64-linux
#   macbook2011 (mac2011)   x86_64-linux
#
# Branch selection: build/update actions detect all local + remote branches.
# If only the default branch exists, it's used automatically without asking.
# If other branches exist (e.g. a feature branch you're testing), you're
# asked which one to check out, pull from, and push to — every time,
# never assumed — before any rebuild happens.
#
# "flake"/"update" flow: select branch -> checkout -> local commit (if
# pending) -> pull -> [flake update, if applicable] -> rebuild -> push
# (if there are commits to send). Everything runs in sequence, without
# returning to the menu mid-process.
#
# Local branch cleanup: once feature branches are merged and deleted on
# origin (e.g. after unifying everything into `main`), the corresponding
# local branches are left behind. Menu option "a" / `prune` finds local
# branches that no longer have a matching branch on origin and offers to
# delete them (the default branch and the currently checked-out branch
# are always kept, never offered for deletion).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIXOS_DIR="${NIXOS_DIR:-$SCRIPT_DIR}"
GIT_DEFAULT_BRANCH="main"
GIT_REPO_URL="git@github.com:waldirborbajr/nixos-config.git"

# Set at runtime by select_git_branch(). Never assume a value beforehand.
GIT_BRANCH=""

# flake attr -> real machine name (used for auto-detection via `hostname`)
declare -A HOST_ATTR_TO_MACHINE=(
  [m2utm]="macutm"
  [dell]="dell1456"
  [macbook2011]="mac2011"
)

# flake attr -> friendly name (display only, used in the menu)
declare -A HOST_ATTR_TO_LABEL=(
  [m2utm]="MacBook M2 - UTM"
  [dell]="Dell Inspiron 1456"
  [macbook2011]="MacBook Pro 13in (2011)"
)

FLAKE_ATTRS=(m2utm dell macbook2011)

# set at runtime by select_flake_attr()
FLAKE_ATTR=""

# ----- colors: Catppuccin Mocha (24-bit ANSI), disabled when not a tty -----
# Same palette as devshell.sh, so both tools look consistent across
# macutm, dell1456 and macbook2011.
if [ -t 1 ]; then
  C_RESET='\033[0m'; C_BOLD='\033[1m'; C_DIM='\033[2m'

  C_MAUVE='\033[38;2;203;166;247m'    # accent / headers
  C_BLUE='\033[38;2;137;180;250m'     # info
  C_SKY='\033[38;2;137;220;235m'      # prompts (replaces plain cyan)
  C_GREEN='\033[38;2;166;227;161m'    # success
  C_YELLOW='\033[38;2;249;226;175m'   # warnings / menu numbers
  C_PEACH='\033[38;2;250;179;135m'    # step markers
  C_RED='\033[38;2;243;139;168m'      # errors / destructive actions
  C_TEAL='\033[38;2;148;226;213m'     # secondary info
  C_TEXT='\033[38;2;205;214;244m'     # default foreground
  C_OVERLAY='\033[38;2;108;112;134m'  # dim / gray

  # kept for backward compatibility with the rest of the script
  C_CYAN="$C_SKY"
  C_MAGENTA="$C_MAUVE"
  C_GRAY="$C_OVERLAY"
else
  C_RESET=''; C_BOLD=''; C_DIM=''
  C_MAUVE=''; C_BLUE=''; C_SKY=''; C_GREEN=''; C_YELLOW=''
  C_PEACH=''; C_RED=''; C_TEAL=''; C_TEXT=''; C_OVERLAY=''
  C_CYAN=''; C_MAGENTA=''; C_GRAY=''
fi

log()  { echo -e "${C_BLUE}${C_BOLD}==>${C_RESET} $*"; }
ok()   { echo -e "${C_GREEN}✓${C_RESET} $*"; }
warn() { echo -e "${C_YELLOW}⚠${C_RESET} $*"; }
err()  { echo -e "${C_RED}✗${C_RESET} $*" >&2; }
step() {
  # step <current> <total> <description>
  echo
  echo -e "${C_MAUVE}${C_BOLD}[$1/$2]${C_RESET} ${C_BOLD}$3${C_RESET}"
}

require_dir() {
  if [ ! -d "$NIXOS_DIR" ]; then
    err "Directory $NIXOS_DIR not found."
    exit 1
  fi
}

check_etc_symlink() {
  # nixos-rebuild switch (legacy mode, without --flake) looks for the
  # config in /etc/nixos by default. Since the repo lives in $NIXOS_DIR,
  # this only works if /etc/nixos is a symlink pointing there.
  if [ -L /etc/nixos ] && [ "$(readlink -f /etc/nixos)" = "$(readlink -f "$NIXOS_DIR")" ]; then
    return 0
  fi
  return 1
}

confirm() {
  # confirm "question" -> returns 0 if yes
  local prompt="$1"
  read -r -p "$(echo -e "${C_SKY}?${C_RESET} ${prompt} ${C_DIM}[y/N]${C_RESET} ")" reply
  [[ "$reply" =~ ^[YySs]$ ]]
}

# ----- initial setup (fresh machine) -----

setup_machine() {
  log "Initial setup for a fresh machine"
  echo

  # 1) Ensure the config repo exists locally
  if [ -d "$NIXOS_DIR" ]; then
    ok "Config repo already present at $NIXOS_DIR"
  else
    warn "Config repo not found at $NIXOS_DIR"
    if confirm "Clone it now from $GIT_REPO_URL (branch $GIT_DEFAULT_BRANCH)?"; then
      git clone --branch "$GIT_DEFAULT_BRANCH" "$GIT_REPO_URL" "$NIXOS_DIR"
      ok "Repo cloned to $NIXOS_DIR"
    else
      err "Cannot continue setup without the config repo. Aborting."
      return 1
    fi
  fi

  # 2) Ensure /etc/nixos is a symlink to the repo
  if check_etc_symlink; then
    ok "/etc/nixos is already correctly symlinked to $NIXOS_DIR"
  else
    if [ -e /etc/nixos ] || [ -L /etc/nixos ]; then
      warn "/etc/nixos already exists and is not the expected symlink."
      if confirm "Back it up to /etc/nixos.bak and replace it with a symlink to $NIXOS_DIR?"; then
        sudo mv /etc/nixos /etc/nixos.bak
        ok "Backed up existing /etc/nixos to /etc/nixos.bak"
      else
        warn "Skipping symlink setup — legacy (non-flake) builds may not work correctly."
        return 0
      fi
    fi
    sudo ln -s "$NIXOS_DIR" /etc/nixos
    ok "Created symlink: /etc/nixos -> $NIXOS_DIR"
  fi

  # 3) Detect / confirm this machine's flake attr
  local detected
  if detected="$(detect_flake_attr)"; then
    ok "This machine's hostname matches flake host: ${C_BOLD}${detected}${C_RESET} (${HOST_ATTR_TO_LABEL[$detected]})"
  else
    warn "This machine's hostname ($(hostname -s 2>/dev/null || echo '?')) does not match any known flake host."
    warn "Check HOST_ATTR_TO_MACHINE in this script, or set the hostname to match one of: ${FLAKE_ATTRS[*]}"
  fi

  echo
  log "Setup complete. You can now run: ./nixos-manager.sh flake"
}

# ----- host/machine selection -----

detect_flake_attr() {
  # tries to match this machine's real hostname against a flake attr
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
  echo -e "${C_SKY}Available hosts:${C_RESET}" >&2
  local i=1 attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo -e "  ${C_YELLOW}${i})${C_RESET} ${C_BOLD}${HOST_ATTR_TO_LABEL[$attr]}${C_RESET} ${C_OVERLAY}(${HOST_ATTR_TO_MACHINE[$attr]})${C_RESET}" >&2
    i=$((i + 1))
  done
  local choice
  read -r -p "$(echo -e "${C_SKY}?${C_RESET} Choose a host [1-${#FLAKE_ATTRS[@]}]: ")" choice
  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#FLAKE_ATTRS[@]}" ]; then
    echo "${FLAKE_ATTRS[$((choice - 1))]}"
    return 0
  fi
  return 1
}

# select_flake_attr [host_arg]
# priority: explicit arg > env NIXOS_FLAKE_ATTR > interactive prompt
# (never assumes a default host — always asks if not explicit)
select_flake_attr() {
  local host_arg="${1:-}"

  if [ -n "$host_arg" ]; then
    if [[ " ${FLAKE_ATTRS[*]} " == *" $host_arg "* ]]; then
      FLAKE_ATTR="$host_arg"
      return 0
    else
      err "Unknown host: $host_arg (options: ${FLAKE_ATTRS[*]})"
      exit 1
    fi
  fi

  if [ -n "${NIXOS_FLAKE_ATTR:-}" ]; then
    if [[ " ${FLAKE_ATTRS[*]} " == *" $NIXOS_FLAKE_ATTR "* ]]; then
      FLAKE_ATTR="$NIXOS_FLAKE_ATTR"
      return 0
    else
      warn "NIXOS_FLAKE_ATTR='$NIXOS_FLAKE_ATTR' is invalid, ignoring."
    fi
  fi

  # No explicit arg and no env var: ALWAYS ask.
  # (Previously tried auto-detecting via hostname, but that can pick the
  # wrong host when the command is run from another machine/session —
  # better to ask every time than assume a default host.)
  if FLAKE_ATTR="$(prompt_flake_attr)"; then
    return 0
  fi

  err "No host selected."
  exit 1
}

# ----- git branch selection -----
#
# Detects all local + remote branches (deduplicated). If only the default
# branch exists, it's selected automatically without prompting — no point
# asking when there's nothing to choose between. If other branches exist
# (e.g. a feature branch under test), the user is always asked, every time,
# never assumed.

list_git_branches() {
  cd "$NIXOS_DIR"
  git fetch --all --prune --quiet 2>/dev/null || true

  {
    git for-each-ref --format='%(refname:short)' refs/heads/ 2>/dev/null
    git for-each-ref --format='%(refname:strip=3)' refs/remotes/origin/ 2>/dev/null
  } | grep -v -E '^(HEAD|origin)$' | grep -v '^$' | sort -u
}

select_git_branch() {
  cd "$NIXOS_DIR"

  local branches=()
  local b
  while IFS= read -r b; do
    [ -n "$b" ] && branches+=("$b")
  done < <(list_git_branches)

  # Fallback: repo with no commits/branches yet, or git command failed.
  if [ "${#branches[@]}" -eq 0 ]; then
    GIT_BRANCH="$GIT_DEFAULT_BRANCH"
    return 0
  fi

  # Only the default branch exists — nothing to choose, skip the prompt.
  if [ "${#branches[@]}" -eq 1 ] && [ "${branches[0]}" = "$GIT_DEFAULT_BRANCH" ]; then
    GIT_BRANCH="$GIT_DEFAULT_BRANCH"
    return 0
  fi

  echo -e "${C_SKY}Branches found:${C_RESET}" >&2
  local i=1
  for b in "${branches[@]}"; do
    if [ "$b" = "$GIT_DEFAULT_BRANCH" ]; then
      echo -e "  ${C_YELLOW}${i})${C_RESET} ${C_BOLD}${b}${C_RESET} ${C_OVERLAY}(default)${C_RESET}" >&2
    else
      echo -e "  ${C_YELLOW}${i})${C_RESET} ${b}" >&2
    fi
    i=$((i + 1))
  done

  local choice
  read -r -p "$(echo -e "${C_SKY}?${C_RESET} Which branch? ${C_DIM}[1-${#branches[@]}, Enter = ${GIT_DEFAULT_BRANCH}]${C_RESET}: ")" choice

  if [ -z "$choice" ]; then
    GIT_BRANCH="$GIT_DEFAULT_BRANCH"
    return 0
  fi

  if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#branches[@]}" ]; then
    GIT_BRANCH="${branches[$((choice - 1))]}"
    return 0
  fi

  warn "Invalid choice — falling back to '${GIT_DEFAULT_BRANCH}'."
  GIT_BRANCH="$GIT_DEFAULT_BRANCH"
}

git_checkout_branch() {
  cd "$NIXOS_DIR"
  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

  if [ "$current" = "$GIT_BRANCH" ]; then
    ok "Already on branch ${C_BOLD}${GIT_BRANCH}${C_RESET}."
    return 0
  fi

  if git show-ref --verify --quiet "refs/heads/${GIT_BRANCH}"; then
    git checkout "$GIT_BRANCH"
  elif git ls-remote --exit-code --heads origin "$GIT_BRANCH" >/dev/null 2>&1; then
    git checkout -b "$GIT_BRANCH" "origin/${GIT_BRANCH}"
  else
    err "Branch '${GIT_BRANCH}' not found locally or on origin."
    return 1
  fi
  ok "Switched to branch ${C_BOLD}${GIT_BRANCH}${C_RESET}."
}

# ----- local branch cleanup -----
#
# After a feature branch is merged and deleted on origin (the goal being
# that, once everything is unified, only `main` remains remotely), the
# matching local branch is left behind with nothing to track. This finds
# local branches that no longer have a corresponding branch on origin and
# offers to remove them. The default branch and whatever branch is
# currently checked out are never candidates for deletion.

prune_local_branches() {
  require_dir
  cd "$NIXOS_DIR"

  log "Fetching from origin (with --prune) to get an up-to-date view..."
  git fetch --all --prune --quiet 2>/dev/null || true

  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"

  local stale=()
  local b
  while IFS= read -r b; do
    [ -z "$b" ] && continue
    [ "$b" = "$GIT_DEFAULT_BRANCH" ] && continue
    [ "$b" = "$current" ] && continue

    if ! git ls-remote --exit-code --heads origin "$b" >/dev/null 2>&1; then
      stale+=("$b")
    fi
  done < <(git for-each-ref --format='%(refname:short)' refs/heads/)

  if [ "${#stale[@]}" -eq 0 ]; then
    ok "No stale local branches found — every local branch (besides '${GIT_DEFAULT_BRANCH}' and the current one) still has a match on origin."
    return 0
  fi

  echo -e "${C_YELLOW}Local branches with no matching branch on origin:${C_RESET}"
  local i=1
  for b in "${stale[@]}"; do
    echo -e "  ${C_YELLOW}${i})${C_RESET} ${b}"
    i=$((i + 1))
  done

  if ! confirm "Delete these ${#stale[@]} stale local branch(es)?"; then
    warn "Cancelled — no branches deleted."
    return 0
  fi

  for b in "${stale[@]}"; do
    if git branch -d "$b" 2>/dev/null; then
      ok "Deleted local branch: ${b}"
    else
      warn "'${b}' is not fully merged into the current branch."
      if confirm "Force delete '${b}' anyway (git branch -D)?"; then
        git branch -D "$b"
        ok "Force-deleted local branch: ${b}"
      else
        warn "Skipped: ${b}"
      fi
    fi
  done
}

# ----- git helpers -----
#
# The git flow is split into independent steps, called in sequence by
# the main actions (build_flake / update_system), WITHOUT returning to
# the menu between steps:
#   1) select_git_branch    -> detects branches, asks if more than one exists
#   2) git_commit_if_dirty  -> commits pending local changes (if any)
#   3) git_checkout_branch  -> switches to the chosen branch
#   4) git_sync_pull        -> pulls in whatever is new on the remote
#   5) git_push_if_ahead    -> pushes local commits not yet sent (at the end)

git_commit_if_dirty() {
  cd "$NIXOS_DIR"
  if [ -z "$(git status --porcelain)" ]; then
    ok "Working tree clean — nothing to commit."
    return 0
  fi

  warn "Uncommitted local changes:"
  git -c color.status=always status --short
  if ! confirm "Commit these changes now and continue with the build?"; then
    warn "Continuing with UNCOMMITTED changes (build will use the current directory state)."
    return 0
  fi

  git add -A
  read -r -p "$(echo -e "${C_SKY}?${C_RESET} Commit message ${C_DIM}[lock: update]${C_RESET}: ")" msg
  msg="${msg:-lock: update}"
  git commit -m "$msg"
  ok "Local commit created."
}

git_sync_pull() {
  cd "$NIXOS_DIR"

  if ! git ls-remote --exit-code --heads origin "$GIT_BRANCH" >/dev/null 2>&1; then
    warn "Branch '${GIT_BRANCH}' doesn't exist on origin yet — skipping pull (local-only branch)."
    return 0
  fi

  log "Pulling changes from branch ${C_BOLD}${GIT_BRANCH}${C_RESET}..."
  git pull origin "$GIT_BRANCH"
}

git_push_if_ahead() {
  cd "$NIXOS_DIR"
  git fetch origin "$GIT_BRANCH" --quiet 2>/dev/null || true

  local ahead
  ahead="$(git rev-list --count "origin/${GIT_BRANCH}..HEAD" 2>/dev/null || echo 0)"

  if [ "$ahead" -eq 0 ]; then
    ok "Nothing to push — already in sync with origin/${GIT_BRANCH}."
    return 0
  fi

  log "$ahead local commit(s) ahead of origin/${GIT_BRANCH}."
  if confirm "Push to ${GIT_BRANCH}?"; then
    git push origin "$GIT_BRANCH"
    ok "Push complete."
  else
    warn "Push cancelled by user — changes remain local only."
  fi
}

# ----- main actions -----

build_legacy() {
  require_dir
  log "Building WITHOUT flake (classic channels)..."

  if check_etc_symlink; then
    sudo nixos-rebuild switch
  else
    warn "/etc/nixos is not a symlink to $NIXOS_DIR — using explicit -I nixos-config."
    sudo nixos-rebuild switch -I nixos-config="${NIXOS_DIR}/configuration.nix"
  fi

  ok "Legacy rebuild complete."
}

build_flake() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"

  step 1 5 "Selecting git branch"
  select_git_branch

  step 2 5 "Checking for local changes"
  git_commit_if_dirty

  step 3 5 "Switching to ${C_TEAL}${GIT_BRANCH}${C_RESET} and syncing"
  git_checkout_branch
  git_sync_pull

  step 4 5 "Applying rebuild — ${C_TEAL}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_OVERLAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Rebuild complete on ${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]} (${FLAKE_ATTR})."

  step 5 5 "Pushing pending changes"
  git_push_if_ahead
}

build_flake_dry() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"

  step 1 3 "Selecting git branch"
  select_git_branch

  step 2 3 "Switching to ${C_TEAL}${GIT_BRANCH}${C_RESET} and syncing"
  git_checkout_branch
  git_sync_pull

  step 3 3 "Test build (not activated) — ${C_TEAL}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_OVERLAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild build --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "Test build complete — nothing was activated. Result in ./result"
}

update_system() {
  local host_arg="${1:-}"
  require_dir
  select_flake_attr "$host_arg"
  cd "$NIXOS_DIR"

  step 1 7 "Selecting git branch"
  select_git_branch

  step 2 7 "Checking for local changes"
  git_commit_if_dirty

  step 3 7 "Switching to ${C_TEAL}${GIT_BRANCH}${C_RESET} and syncing"
  git_checkout_branch
  git_sync_pull

  step 4 7 "Updating flake.lock (nix flake update)"
  sudo nix flake update

  step 5 7 "Committing updated flake.lock (if changed)"
  git_commit_if_dirty

  step 6 7 "Applying rebuild — ${C_TEAL}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} ${C_OVERLAY}(${FLAKE_ATTR})${C_RESET}"
  sudo nixos-rebuild switch --flake "${NIXOS_DIR}#${FLAKE_ATTR}"
  ok "System updated on ${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]} (${FLAKE_ATTR})."

  step 7 7 "Pushing pending changes"
  git_push_if_ahead
}

rollback_system() {
  log "Available generations:"
  sudo nix-env --list-generations -p /nix/var/nix/profiles/system
  if confirm "Roll back to the previous generation?"; then
    sudo nixos-rebuild switch --rollback
    ok "Rollback complete."
  else
    warn "Cancelled."
  fi
}

clean_cache() {
  local mode_arg="${1:-}"
  log "Cleaning old generations and collecting Nix store garbage..."

  local mode="$mode_arg"
  if [ -z "$mode" ]; then
    echo -e "  ${C_YELLOW}1)${C_RESET} Quick      — remove generations older than 14 days"
    echo -e "  ${C_RED}2)${C_RESET} Aggressive — remove ALL old generations (nix-collect-garbage -d)"
    read -r -p "$(echo -e "${C_SKY}?${C_RESET} Choose [1/2]: ")" mode
  fi

  case "$mode" in
    1)
      sudo nix-collect-garbage --delete-older-than 14d
      ;;
    2)
      if [ -n "$mode_arg" ] || confirm "This removes ALL old generations, including rollback. Confirm?"; then
        sudo nix-collect-garbage -d
      else
        warn "Cancelled."
        return 0
      fi
      ;;
    *)
      err "Invalid option."
      return 1
      ;;
  esac

  log "Optimizing the store (hardlink deduplication)..."
  sudo nix-store --optimise
  ok "Store cleanup complete."

  # The cleanup above removes profile/store generations, but does NOT
  # update the bootloader. Without this step, entries for already-removed
  # generations keep showing up in the boot menu (systemd-boot/GRUB),
  # pointing at something that no longer exists — worse than useless,
  # it's a broken-boot risk.
  log "Syncing bootloader with the remaining generations..."
  if confirm "Run 'nixos-rebuild boot' to update the boot menu now?"; then
    sudo nixos-rebuild boot
    ok "Bootloader updated — the boot menu now reflects only the generations that still exist."
  else
    warn "Bootloader NOT updated — the boot menu may keep showing removed generations until you run 'sudo nixos-rebuild boot' manually."
  fi

  log "Current disk usage:"
  df -h /nix/store 2>/dev/null || df -h /
}

check_flake() {
  local host_arg="${1:-}"
  require_dir
  cd "$NIXOS_DIR"

  if [ -n "$host_arg" ]; then
    select_flake_attr "$host_arg"
    log "Checking flake for host ${C_BOLD}${HOST_ATTR_TO_LABEL[$FLAKE_ATTR]}${C_RESET} (${FLAKE_ATTR})..."
  else
    log "Checking flake (all hosts)..."
  fi

  if nix flake check --print-build-logs; then
    ok "Flake check passed successfully."
  else
    err "Flake check failed. See output above."
    exit 1
  fi
}

list_hosts() {
  echo -e "${C_BOLD}${C_SKY}Hosts configured in the flake:${C_RESET}"
  local attr
  for attr in "${FLAKE_ATTRS[@]}"; do
    echo -e "  ${C_GREEN}●${C_RESET} ${C_BOLD}${HOST_ATTR_TO_LABEL[$attr]}${C_RESET}  ${C_OVERLAY}(attr: ${attr}, hostname: ${HOST_ATTR_TO_MACHINE[$attr]})${C_RESET}"
  done
  local detected
  echo
  if detected="$(detect_flake_attr)"; then
    ok "This machine matches: ${C_BOLD}${detected}${C_RESET}"
  else
    warn "This machine ($(hostname -s 2>/dev/null || echo '?')) does not match any known host."
  fi
}

list_branches_cmd() {
  require_dir
  cd "$NIXOS_DIR"
  git fetch --all --prune --quiet 2>/dev/null || true
  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
  echo -e "${C_BOLD}${C_SKY}Branches (local + remote, deduplicated):${C_RESET}"
  local b
  while IFS= read -r b; do
    [ -z "$b" ] && continue

    if [ "$b" = "$current" ]; then
      echo -e "  ${C_GREEN}●${C_RESET} ${C_BOLD}${b}${C_RESET} ${C_OVERLAY}(current)${C_RESET}"
    elif git show-ref --verify --quiet "refs/heads/${b}" && ! git ls-remote --exit-code --heads origin "$b" >/dev/null 2>&1; then
      echo -e "  ${C_YELLOW}○${C_RESET} ${b} ${C_OVERLAY}(local only — no match on origin)${C_RESET}"
    else
      echo -e "  ${C_OVERLAY}○${C_RESET} ${b}"
    fi
  done < <(list_git_branches)
}

# ----- menu -----

print_banner() {
  local detected
  detected="$(detect_flake_attr 2>/dev/null || echo 'not identified')"
  echo
  echo -e "${C_MAUVE}╭──────────────────────────────────────╮${C_RESET}"
  printf "${C_MAUVE}│${C_RESET}  ${C_BOLD}${C_TEXT}NixOS Manager${C_RESET}%*s${C_MAUVE}│${C_RESET}\n" 24 ""
  echo -e "${C_MAUVE}│${C_RESET}  ${C_OVERLAY}this machine: ${C_RESET}${C_GREEN}${detected}${C_RESET}$(printf '%*s' $((25 - ${#detected})) '')${C_MAUVE}│${C_RESET}"
  echo -e "${C_MAUVE}╰──────────────────────────────────────╯${C_RESET}"
  echo -e "  ${C_OVERLAY}${C_DIM}(host and git branch are always asked — nothing is assumed)${C_RESET}"
}

show_menu() {
  print_banner
  echo
  echo -e " ${C_GREEN}${C_BOLD}0)${C_RESET} Initial setup"
  echo -e " ${C_YELLOW}${C_BOLD}1)${C_RESET} Build without flake"
  echo -e " ${C_YELLOW}${C_BOLD}2)${C_RESET} Build with flake"
  echo -e " ${C_YELLOW}${C_BOLD}3)${C_RESET} Clean cache"
  echo -e " ${C_YELLOW}${C_BOLD}4)${C_RESET} Update system"
  echo -e " ${C_YELLOW}${C_BOLD}5)${C_RESET} Test build (dry)"
  echo -e " ${C_RED}${C_BOLD}6)${C_RESET} Rollback"
  echo -e " ${C_YELLOW}${C_BOLD}7)${C_RESET} Check flake ${C_OVERLAY}(nix flake check)${C_RESET}"
  echo -e " ${C_BLUE}${C_BOLD}8)${C_RESET} List hosts"
  echo -e " ${C_BLUE}${C_BOLD}9)${C_RESET} List branches"
  echo -e " ${C_RED}${C_BOLD}a)${C_RESET} Prune local branches ${C_OVERLAY}(no match on origin)${C_RESET}"
  echo -e " ${C_BOLD}q)${C_RESET} Quit"
  echo
}

run_choice() {
  local choice="$1"
  local extra_arg="${2:-}"
  case "$choice" in
    0|setup) setup_machine ;;
    1|legacy) build_legacy ;;
    2|flake) build_flake "$extra_arg" ;;
    3|clean) clean_cache "$extra_arg" ;;
    4|update) update_system "$extra_arg" ;;
    5|dry) build_flake_dry "$extra_arg" ;;
    6|rollback) rollback_system ;;
    7|check) check_flake "$extra_arg" ;;
    8|hosts) list_hosts ;;
    9|branches) list_branches_cmd ;;
    a|A|prune) prune_local_branches ;;
    q|quit|exit) exit 0 ;;
    *) err "Invalid option: $choice"; return 1 ;;
  esac
}

main() {
  if [ $# -ge 1 ]; then
    run_choice "$1" "${2:-}"
    exit $?
  fi

  while true; do
    show_menu
    read -r -p "$(echo -e "${C_SKY}?${C_RESET} Choose an option: ")" choice
    run_choice "$choice" || true
  done
}

main "$@"
