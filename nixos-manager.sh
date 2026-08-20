#!/usr/bin/env bash
# nixos-manager.sh - NixOS management script with standardized hostnames

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${SCRIPT_DIR}"
NIXOS_DIR="${REPO_ROOT}"

# Known hosts (standardized names)
declare -A HOSTS
HOSTS=(
  ["dell1564"]="Dell Inspiron 1564"
  ["mac2011"]="MacBook Pro 13in (2011)"
  ["macutm"]="Mac M2 - UTM"
  ["macvmf"]="Mac M2 - VMware Fusion"
)

# Aliases for backward compatibility (deprecated)
declare -A HOST_ALIASES
HOST_ALIASES=(
  ["macbook2011"]="mac2011"
  ["dell"]="dell1564"
  ["mac"]="mac2011"
  ["m2utm"]="macutm"
)

# --- Helper Functions ---

print_info() {
  echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
  echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
  echo -e "${RED}✗${NC} $1"
}

# Resolve host alias to canonical name
resolve_host() {
  local host="$1"
  if [[ -n "${HOST_ALIASES[$host]:-}" ]]; then
    local canonical="${HOST_ALIASES[$host]}"
    print_warning "Using legacy alias '$host' → '$canonical'"
    echo "$canonical"
  elif [[ -n "${HOSTS[$host]:-}" ]]; then
    echo "$host"
  else
    print_error "Unknown host: $host"
    echo ""
    return 1
  fi
}

# Validate host exists
validate_host() {
  local host="$1"
  if [[ -z "${HOSTS[$host]:-}" ]]; then
    print_error "Unknown host: $host"
    echo ""
    echo "Available hosts:"
    for h in "${!HOSTS[@]}"; do
      echo "  - $h (${HOSTS[$h]})"
    done
    return 1
  fi
  return 0
}

# Detect current host
detect_host() {
  local current_hostname="$(hostname)"
  # Try to resolve alias first
  local resolved=$(resolve_host "$current_hostname" 2>/dev/null || echo "")
  if [[ -n "$resolved" ]]; then
    echo "$resolved"
    return 0
  fi
  # Check if it's directly a known host
  if [[ -n "${HOSTS[$current_hostname]:-}" ]]; then
    echo "$current_hostname"
    return 0
  fi
  # Not found
  echo ""
  return 1
}

# Get rebuild flags based on host (e.g., serial builds for low RAM)
rebuild_extra_flags() {
  local host="$1"
  case "$host" in
    dell1564)
      # Dell has limited RAM, force serial builds
      echo "--cores 1"
      ;;
    *)
      echo ""
      ;;
  esac
}

# --- Core Functions ---

setup() {
  print_info "Setting up /etc/nixos symlink..."
  if [[ -L /etc/nixos ]]; then
    print_warning "/etc/nixos is already a symlink. Removing..."
    sudo rm /etc/nixos
  elif [[ -d /etc/nixos ]]; then
    print_warning "/etc/nixos exists as directory. Moving to /etc/nixos.bak..."
    sudo mv /etc/nixos /etc/nixos.bak
  fi
  sudo ln -s "$NIXOS_DIR" /etc/nixos
  print_success "Symlink created: /etc/nixos -> $NIXOS_DIR"

  # Detect and suggest host
  local detected_host=$(detect_host 2>/dev/null || echo "")
  if [[ -n "$detected_host" ]]; then
    print_info "Detected host: $detected_host (${HOSTS[$detected_host]})"
  else
    print_warning "Could not detect known host. Current hostname: $(hostname)"
    print_info "Available hosts:"
    for host in "${!HOSTS[@]}"; do
      echo "  - $host (${HOSTS[$host]})"
    done
  fi
}

# List available hosts
list_hosts() {
  echo "Available hosts:"
  for host in "${!HOSTS[@]}"; do
    echo "  $host - ${HOSTS[$host]}"
  done
  echo ""
  echo "Legacy aliases (deprecated):"
  for alias in "${!HOST_ALIASES[@]}"; do
    echo "  $alias → ${HOST_ALIASES[$alias]}"
  done
}

# Interactive host selection
select_host() {
  local host_list=()
  local i=0
  echo "Select host:"
  for h in "${!HOSTS[@]}"; do
    host_list+=("$h")
    echo "  $i) $h - ${HOSTS[$h]}"
    ((i++))
  done
  read -p "Select host [0-$((i-1))]: " selection
  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -lt "${#host_list[@]}" ]; then
    echo "${host_list[$selection]}"
  else
    print_error "Invalid selection"
    return 1
  fi
}

# Interactive branch selection
select_branch() {
  local branches
  branches=$(git branch --format="%(refname:short)" | grep -v "HEAD" || true)
  local branch_count
  branch_count=$(echo "$branches" | wc -l | tr -d ' ')

  if [[ -z "$branches" ]]; then
    echo "main"
    return
  fi

  if [[ "$branch_count" -eq 1 ]]; then
    echo "$branches"
    return
  fi

  # More than one branch, ask user
  echo "Available branches:"
  local i=0
  local branch_list=()
  while IFS= read -r branch; do
    if [[ -n "$branch" ]]; then
      branch_list+=("$branch")
      echo "  $i) $branch"
      ((i++))
    fi
  done <<< "$branches"

  # Determine default selection
  local default_branch="main"
  local default_index=0
  for idx in "${!branch_list[@]}"; do
    if [[ "${branch_list[$idx]}" == "$default_branch" ]]; then
      default_index=$idx
      break
    fi
  done

  echo ""
  read -p "Select branch [default $default_index]: " selection
  selection="${selection:-$default_index}"

  if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -lt "${#branch_list[@]}" ]; then
    echo "${branch_list[$selection]}"
  else
    echo "main"
  fi
}

# Rebuild with flake
rebuild_flake() {
  local host="${1:-}"
  local branch="${2:-}"

  # If no host provided, try to detect or ask
  if [[ -z "$host" ]]; then
    host=$(detect_host 2>/dev/null || echo "")
    if [[ -z "$host" ]]; then
      host=$(select_host) || return 1
    else
      print_info "Auto-detected host: $host"
    fi
  else
    # Resolve alias if needed
    local resolved=$(resolve_host "$host" 2>/dev/null || echo "")
    if [[ -n "$resolved" ]]; then
      host="$resolved"
    fi
  fi

  # Validate host
  validate_host "$host" || return 1

  # Select branch if not provided
  if [[ -z "$branch" ]]; then
    branch=$(select_branch)
  fi

  print_info "Building for host: $host (branch: $branch)"

  # Check git status
  if ! git diff --quiet || ! git diff --cached --quiet; then
    print_warning "Uncommitted changes detected. Commit or stash before rebuilding."
    if [[ -t 0 ]]; then
      read -p "Continue anyway? [y/N]: " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 1
      fi
    else
      print_error "Uncommitted changes. Exiting."
      return 1
    fi
  fi

  # Switch to branch
  git checkout "$branch" 2>/dev/null || print_warning "Branch $branch not found, staying on current branch"
  git pull origin "$branch" 2>/dev/null || true

  # Commit any pending changes
  if ! git diff --quiet; then
    print_info "Committing pending changes..."
    git add .
    git commit -m "auto: pending changes before rebuild" || true
  fi

  # Rebuild
  local extra_flags
  extra_flags=$(rebuild_extra_flags "$host")

  print_info "Running: nixos-rebuild switch --flake .#$host $extra_flags"
  if nixos-rebuild switch --flake .#"$host" $extra_flags; then
    print_success "Rebuild successful!"

    # Push changes if any
    if ! git diff --quiet origin/"$branch" 2>/dev/null || ! git diff --cached --quiet; then
      print_info "Pushing changes to origin..."
      git push origin "$branch"
    fi
  else
    print_error "Rebuild failed!"
    return 1
  fi
}

# Update flake inputs
update_flake() {
  local host="${1:-}"
  local branch="${2:-}"

  if [[ -z "$host" ]]; then
    host=$(detect_host 2>/dev/null || echo "")
    if [[ -z "$host" ]]; then
      host=$(select_host) || return 1
    else
      print_info "Auto-detected host: $host"
    fi
  else
    local resolved=$(resolve_host "$host" 2>/dev/null || echo "")
    if [[ -n "$resolved" ]]; then
      host="$resolved"
    fi
  fi

  validate_host "$host" || return 1

  if [[ -z "$branch" ]]; then
    branch=$(select_branch)
  fi

  print_info "Updating flake for host: $host (branch: $branch)"

  git checkout "$branch" 2>/dev/null || print_warning "Branch $branch not found, staying on current branch"
  git pull origin "$branch" 2>/dev/null || true

  print_info "Running: nix flake update"
  nix flake update

  print_info "Rebuilding after update..."
  rebuild_flake "$host" "$branch"
}

# Clean cache
clean_cache() {
  echo "Select cleanup mode:"
  echo "  1) Quick (remove generations older than 14 days)"
  echo "  2) Aggressive (collect garbage)"
  read -p "Select mode [1-2]: " mode

  case "$mode" in
    1)
      print_info "Removing generations older than 14 days..."
      nix-collect-garbage --delete-older-than 14d
      ;;
    2)
      print_info "Aggressive garbage collection..."
      nix-collect-garbage -d
      ;;
    *)
      print_error "Invalid selection"
      return 1
      ;;
  esac

  print_info "Syncing bootloader..."
  nixos-rebuild boot
  print_success "Cleanup complete"
}

# Rollback to previous generation
rollback() {
  print_info "Rolling back to previous generation..."
  nixos-rebuild switch --rollback
  print_success "Rollback complete"
}

# Dry run - check configuration
dry_run() {
  local host="${1:-}"

  if [[ -z "$host" ]]; then
    host=$(detect_host 2>/dev/null || echo "")
    if [[ -z "$host" ]]; then
      host=$(select_host) || return 1
    else
      print_info "Auto-detected host: $host"
    fi
  else
    local resolved=$(resolve_host "$host" 2>/dev/null || echo "")
    if [[ -n "$resolved" ]]; then
      host="$resolved"
    fi
  fi

  validate_host "$host" || return 1

  print_info "Dry run for host: $host"
  nixos-rebuild build --flake .#"$host" --dry-run
  print_success "Dry run complete"
}

# Check flake
check_flake() {
  local host="${1:-}"

  if [[ -n "$host" ]]; then
    local resolved=$(resolve_host "$host" 2>/dev/null || echo "")
    if [[ -n "$resolved" ]]; then
      host="$resolved"
    fi
    validate_host "$host" || return 1
    print_info "Checking flake for host: $host"
    nix flake check .#"$host" --print-build-logs
  else
    print_info "Checking flake..."
    nix flake check --print-build-logs
  fi
}

# Show current generation
show_generation() {
  print_info "Current system generation:"
  nixos-version
  echo ""
  echo "Boot entries:"
  bootctl list || echo "Could not list boot entries (not using systemd-boot?)"
}

# --- Main Menu ---

show_menu() {
  echo ""
  echo "╔═══════════════════════════════════════════╗"
  echo "║    ❄️  NixOS Manager - Menu              ║"
  echo "╠═══════════════════════════════════════════╣"
  echo "║  0) Setup initial symlink                ║"
  echo "║  1) Legacy rebuild (non-flake)           ║"
  echo "║  2) Flake rebuild                        ║"
  echo "║  3) Clean cache                          ║"
  echo "║  4) Update flake inputs                  ║"
  echo "║  5) Dry run (build only)                 ║"
  echo "║  6) Rollback                             ║"
  echo "║  7) Check flake                          ║"
  echo "║  8) List hosts                           ║"
  echo "║  9) Show current generation              ║"
  echo "║  q) Quit                                 ║"
  echo "╚═══════════════════════════════════════════╝"
  echo ""
}

# --- Argument Parsing ---

if [[ $# -gt 0 ]]; then
  case "$1" in
    setup)
      setup
      ;;
    legacy)
      print_warning "Legacy mode is deprecated. Use 'flake' instead."
      nixos-rebuild switch
      ;;
    flake)
      host="${2:-}"
      branch="${3:-}"
      rebuild_flake "$host" "$branch"
      ;;
    clean)
      clean_cache
      ;;
    update)
      host="${2:-}"
      branch="${3:-}"
      update_flake "$host" "$branch"
      ;;
    dry)
      host="${2:-}"
      dry_run "$host"
      ;;
    rollback)
      rollback
      ;;
    check)
      host="${2:-}"
      check_flake "$host"
      ;;
    hosts)
      list_hosts
      ;;
    generation)
      show_generation
      ;;
    *)
      echo "Usage: $0 [setup|legacy|flake|clean|update|dry|rollback|check|hosts|generation]"
      echo "       $0 flake [host] [branch]"
      echo "       $0 update [host] [branch]"
      echo "       $0 dry [host]"
      echo "       $0 check [host]"
      echo "       $0 [hosts|generation]"
      exit 1
      ;;
  esac
else
  # Interactive menu
  while true; do
    show_menu
    read -p "Enter your choice: " choice
    echo ""

    case "$choice" in
      0) setup ;;
      1) print_warning "Legacy rebuild"; nixos-rebuild switch ;;
      2) rebuild_flake ;;
      3) clean_cache ;;
      4) update_flake ;;
      5) dry_run ;;
      6) rollback ;;
      7) check_flake ;;
      8) list_hosts ;;
      9) show_generation ;;
      q|Q) echo "Goodbye!"; exit 0 ;;
      *) print_error "Invalid choice" ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
  done
fi
