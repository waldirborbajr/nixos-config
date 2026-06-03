# ==========================================
# NixOS Infra Justfile (Borba - NixGuru edition)
# ==========================================
set shell := ["bash", "-euo", "pipefail", "-c"]
set dotenv-load := true

# Variables
DEBUG_LOG := "/tmp/nixos-build-debug.log"
GIT_PUSH := env_var_or_default("GIT_PUSH", "1")
AUTO_UPDATE_FLAKE := env_var_or_default("AUTO_UPDATE_FLAKE", "0")
AUTO_GIT_COMMIT := env_var_or_default("AUTO_GIT_COMMIT", "1")

REMOTE_USER := env_var_or_default("REMOTE_USER", "borba")
MACBOOK_HOST := env_var_or_default("MACBOOK_HOST", "macbook.lan")
DELL_HOST := env_var_or_default("DELL_HOST", "dell.lan")

_git_commit_msg := "wip(justfile): " + `date '+%Y-%m-%d %H:%M'`

# ==========================================
# Default recipe
# ==========================================
default:
    @just --list

# ==========================================
# Discovery / Diagnostics
# ==========================================
[group: 'discovery']
hosts:
    if [[ ! -e "flake.nix" ]]; then
        echo "ERROR: flake.nix not found"
        exit 1
    fi
    echo "Available hosts:"
    nix --extra-experimental-features "nix-command flakes" flake show --json \
        | jq -r '.nixosConfigurations | keys[]' 2>/dev/null || \
        (echo "Install jq or run: just flake-show"; exit 0)

flake-show:
    nix --extra-experimental-features "nix-command flakes" flake show

doctor:
    if [[ ! -e "flake.nix" ]]; then
        echo "ERROR: flake.nix not found"; exit 1
    fi
    if ! command -v nix >/dev/null; then
        echo "ERROR: nix command not found"; exit 1
    fi
    nix --extra-experimental-features "nix-command flakes" flake show >/dev/null 2>&1
    echo "OK: repo + nix + flakes look good."

# ==========================================
# Validation
# ==========================================
[group: 'validation']
flake-check:
    @echo "Running flake check..."
    @nix --extra-experimental-features "nix-command flakes" flake check

check:
    @echo "Checking flake syntax (impure)..."
    @nix --extra-experimental-features "nix-command flakes" flake check --impure
    @echo "✓ Syntax OK!"

eval-host HOST="macbook":
    if [[ -z "{{HOST}}" ]]; then
        echo "ERROR: HOST required"; exit 1
    fi
    echo "Evaluating host {{HOST}}..."
    nix --extra-experimental-features "nix-command flakes" eval --raw \
        ".#nixosConfigurations.{{HOST}}.config.system.build.toplevel.drvPath"

# ==========================================
# Git operations
# ==========================================
[group: 'git']
update-flake:
    @echo "Updating flake.lock..."
    @nix --extra-experimental-features "nix-command flakes" flake update

[private]
_check_git_status:
    echo "Checking Git status..."
    if [ -z "$(git status --porcelain)" ]; then
        echo "Git tree clean"
    else
        git add .
        git commit -m "{{_git_commit_msg}}" || true
        if [ "{{GIT_PUSH}}" = "1" ]; then git push origin main || true; fi
    fi

# ==========================================
# Internal build helpers
# ==========================================
[group: 'build']
[private]
_require_host HOST:
    if [[ -z "{{HOST}}" ]]; then
        echo "ERROR: HOST required"; exit 1
    fi
    nix --extra-experimental-features "nix-command flakes" eval --raw \
        ".#nixosConfigurations.{{HOST}}.config.system.build.toplevel.drvPath" >/dev/null 2>&1 \
        || { echo "ERROR: HOST '{{HOST}}' not found"; exit 1; }

[private]
_nixos_cmd HOST ACTION DEVOPS="" QEMU="" IMPURE="" FLAGS="":
    CMD="sudo nixos-rebuild {{ACTION}} --flake .#{{HOST}}"
    [[ -n "{{IMPURE}}" ]] && CMD="$CMD --impure"
    [[ -n "{{FLAGS}}" ]] && CMD="$CMD {{FLAGS}}"
    [[ -n "{{DEVOPS}}" ]] && export DEVOPS=1
    [[ -n "{{QEMU}}" ]] && export QEMU=1
    echo ">>> Running: $CMD"
    eval $CMD

# ==========================================
# Remote deployment helpers
# ==========================================
[group: 'deploy']
[private]
_remote_target HOST:
    case "{{HOST}}" in
        macbook) echo "{{REMOTE_USER}}@{{MACBOOK_HOST}}" ;;
        dell) echo "{{REMOTE_USER}}@{{DELL_HOST}}" ;;
        *) echo "ERROR: unknown host '{{HOST}}'"; exit 1 ;;
    esac

deploy-dry HOST="macbook" IMPURE="":
    @just _require_host {{HOST}}
    @TARGET="$$(just --evaluate _remote_target {{HOST}})"
    sudo nixos-rebuild dry-activate \
        --flake .#{{HOST}} \
        --target-host "$$TARGET" \
        --use-remote-sudo \
        {{ if IMPURE != "" { "--impure" } else { "" } }}

deploy HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || true
    @just _check_git_status
    @just flake-check
    TARGET="$$(just --evaluate _remote_target {{HOST}})"
    [[ -n "{{DEVOPS}}" ]] && export DEVOPS=1
    [[ -n "{{QEMU}}" ]] && export QEMU=1
    CMD="sudo nixos-rebuild switch \
        --flake .#{{HOST}} \
        --target-host $$TARGET \
        --use-remote-sudo \
        --show-trace"
    [[ -n "{{IMPURE}}" ]] && CMD="$CMD --impure"
    echo "$CMD"
    eval "$CMD"

deploy-remote-build HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    TARGET="$$(just --evaluate _remote_target {{HOST}})"
    [[ -n "{{DEVOPS}}" ]] && export DEVOPS=1
    [[ -n "{{QEMU}}" ]] && export QEMU=1
    CMD="sudo nixos-rebuild switch \
        --flake .#{{HOST}} \
        --target-host $$TARGET \
        --build-host $$TARGET \
        --use-remote-sudo \
        --show-trace"
    [[ -n "{{IMPURE}}" ]] && CMD="$CMD --impure"
    echo "$CMD"
    eval "$CMD"

# ==========================================
# Existing build/switch recipes
# ==========================================
dry-switch HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}} "--dry-run"

dry-build HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}} "--dry-run"

test-build HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @echo "Test build (no changes applied) for host {{HOST}}"
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}}
    @echo "✓ Test build complete!"

build HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "Skipping flake update"
    @just _check_git_status
    @just flake-check
    @just _nixos_cmd {{HOST}} build {{DEVOPS}} {{QEMU}} {{IMPURE}}

switch HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "Skipping flake update"
    @just _check_git_status
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}

switch-prod HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    @[ "{{AUTO_UPDATE_FLAKE}}" = "1" ] && just update-flake || echo "Skipping flake update"
    @just _check_git_status
    @just flake-check
    @just _nixos_cmd {{HOST}} switch {{DEVOPS}} {{QEMU}} {{IMPURE}}

switch-off HOST="macbook" DEVOPS="" QEMU="" IMPURE="":
    @just _require_host {{HOST}}
    sudo systemctl isolate multi-user.target
    @just

# ==========================================
# Maintenance
# ==========================================
[group: 'maintenance']
gc:
    @echo "Collecting Nix garbage..."
    nix store gc --verbose \
        --option keep-build-log false \
        --option keep-derivations false \
        --option keep-env-derivations false \
        --option keep-failed false \
        --option keep-going false \
        --option keep-outputs false
    nix-collect-garbage --delete-old
    nix store optimise --verbose
    @echo "Disk usage after GC:"
    du -cksh /nix
