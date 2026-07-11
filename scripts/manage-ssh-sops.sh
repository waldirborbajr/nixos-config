#!/usr/bin/env bash
#
# ssh-keys-to-sops.sh — generates SSH keys (infra, github, host) and syncs
# them into the per-host SOPS secrets file with a correct YAML structure.
#
# Usage:
#   ./ssh-keys-to-sops.sh                  # incremental update, current hostname
#   ./ssh-keys-to-sops.sh dell             # or dell1456
#   ./ssh-keys-to-sops.sh mac2011          # or mac, macbook2011
#   ./ssh-keys-to-sops.sh macutm           # or m2utm
#   ./ssh-keys-to-sops.sh macutm --clean   # wipe local keys + secrets file,
#                                          # regenerate everything from scratch
#
# Modes:
#   default    -> uses `sops set` per key, preserving any unrelated secret
#                 already present in the file (safe to re-run repeatedly).
#   --clean    -> deletes local SSH keypairs and the secrets file, then
#                 rebuilds the whole encrypted YAML from a single clean
#                 in-memory document. Use this once per host to fix a file
#                 that got corrupted by a previous broken run (e.g. the
#                 "data: |" wrapper bug caused by encrypting an extensionless
#                 temp file without an explicit --input-type).
#
# Root cause this script avoids: sops infers input format from the file
# extension unless told otherwise. Encrypting a temp file with no .yaml
# extension makes sops fall back to wrapping everything under a single
# `data:` key instead of real top-level keys. This script always passes
# --input-type yaml explicitly, regardless of temp file naming.
#
# First-install bootstrap: on a brand-new machine, none of age/sops/jq/
# ssh-keygen exist yet (they only land on PATH after the first
# nixos-rebuild). If any are missing, this script re-execs itself inside
# `nix shell nixpkgs#age nixpkgs#sops nixpkgs#jq nixpkgs#openssh -c ...`
# so it's usable before the system has ever been built.

set -euo pipefail

CLEAN=false
host_arg=""
for arg in "$@"; do
  case "$arg" in
    --clean) CLEAN=true ;;
    *) host_arg="$arg" ;;
  esac
done

hostname_now="$(hostname)"
case "${host_arg:-$hostname_now}" in
  dell|dell1456)
    host="dell1456"
    ;;
  mac|mac2011|macbook2011)
    host="mac2011"
    ;;
  m2utm|macutm)
    host="macutm"
    ;;
  *)
    host="${host_arg:-$hostname_now}"
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets_file="$repo_root/hosts/$host/secrets/$host.yaml"
host_key_path="/etc/ssh/ssh_host_ed25519_key"

if [[ ! -d "$repo_root/hosts/$host" ]]; then
  echo "Host directory not found: $repo_root/hosts/$host" >&2
  exit 1
fi

# ----- First-install bootstrap: re-exec inside `nix shell` if tools are missing -----
# On a fresh machine (before the first nixos-rebuild), age/sops/jq/ssh-keygen
# aren't on PATH yet. Rather than failing, pull them in via `nix shell` and
# re-run this same script inside it. The env guard prevents infinite
# recursion if a tool is still missing even inside that shell.
missing_tool=false
for tool in ssh-keygen age-keygen sops jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    missing_tool=true
    break
  fi
done

if $missing_tool; then
  if [[ -n "${MANAGE_SSH_SOPS_NIX_SHELL_WRAPPED:-}" ]]; then
    echo "Required tool(s) still missing even inside 'nix shell' (age/sops/jq/openssh). Aborting." >&2
    exit 1
  fi
  echo "age/sops/jq/ssh-keygen not found on PATH (first install?) — re-running inside 'nix shell'..." >&2
  exec env MANAGE_SSH_SOPS_NIX_SHELL_WRAPPED=1 nix --extra-experimental-features "nix-command flakes" shell nixpkgs#age nixpkgs#sops nixpkgs#jq nixpkgs#openssh -c "$0" "$@"
fi

mkdir -p "$HOME/.ssh" "$HOME/.config/sops/age"
chmod 700 "$HOME/.ssh"

age_key_file="$HOME/.config/sops/age/keys.txt"
export SOPS_AGE_KEY_FILE="$age_key_file"

if [[ ! -f "$age_key_file" ]]; then
  age-keygen -o "$age_key_file" >/dev/null
  chmod 600 "$age_key_file"
fi

age_recipient="$(age-keygen -y "$age_key_file")"

# ----- --clean: wipe local keys + secrets file, start fresh -----
if $CLEAN; then
  echo "Cleaning local SSH keys and secrets file for host '$host'..."
  rm -f "$HOME/.ssh/id_ed25519_infra" "$HOME/.ssh/id_ed25519_infra.pub"
  rm -f "$HOME/.ssh/id_ed25519_github" "$HOME/.ssh/id_ed25519_github.pub"
  rm -f "$secrets_file"
fi

# ----- Generate SSH keypairs (idempotent: skips if already present) -----
for kind in infra github; do
  key_path="$HOME/.ssh/id_ed25519_${kind}"
  if [[ ! -f "$key_path" ]]; then
    ssh-keygen -q -t ed25519 -C "${kind}@${host}" -N "" -f "$key_path"
  fi
done

# ----- Host key: generate locally if it doesn't exist yet -----
# Normally created by the ssh-hostkey-bootstrap systemd service on first
# activation, but generating it here too makes this script fully
# self-sufficient during initial setup, before the first rebuild has run.
if [[ ! -f "$host_key_path" ]]; then
  echo "Host key not found at $host_key_path — generating now (requires sudo)..."
  sudo mkdir -p /etc/ssh
  sudo ssh-keygen -q -t ed25519 -N "" -f "$host_key_path"
fi

if $CLEAN; then
  # ----- Full clean rebuild: construct one valid YAML document and encrypt -----
  # --input-type yaml is explicit here (not inferred from extension), which
  # is exactly what avoids the "data: |" wrapper bug from before.
  tmp_file="$(mktemp --suffix=.yaml)"
  trap 'rm -f "$tmp_file"' EXIT

  {
    echo "borba_ssh_infra_private_key: |"
    sed 's/^/  /' "$HOME/.ssh/id_ed25519_infra"
    echo "borba_ssh_infra_public_key: $(cat "$HOME/.ssh/id_ed25519_infra.pub")"
    echo "borba_ssh_github_private_key: |"
    sed 's/^/  /' "$HOME/.ssh/id_ed25519_github"
    echo "borba_ssh_github_public_key: $(cat "$HOME/.ssh/id_ed25519_github.pub")"
    echo "ssh_host_ed25519_key: |"
    sudo sed 's/^/  /' "$host_key_path"
  } > "$tmp_file"

  sops --encrypt --input-type yaml --output-type yaml --age "$age_recipient" "$tmp_file" > "$secrets_file"
  chmod 600 "$secrets_file"

  echo "Secrets file rebuilt from scratch: $secrets_file"
else
  # ----- Incremental mode: sops set per key, preserves unrelated secrets -----
  if [[ ! -f "$secrets_file" ]]; then
    echo "{}" | sops --encrypt --input-type json --output-type yaml --age "$age_recipient" /dev/stdin > "$secrets_file"
    chmod 600 "$secrets_file"
    echo "Created new empty secrets file: $secrets_file"
  fi

  set_key() {
    local key="$1" value_json="$2"
    sops set "$secrets_file" "[\"${key}\"]" "$value_json"
  }

  set_key "borba_ssh_infra_private_key"  "$(jq -Rs . < "$HOME/.ssh/id_ed25519_infra")"
  set_key "borba_ssh_infra_public_key"   "$(jq -Rs . < "$HOME/.ssh/id_ed25519_infra.pub")"
  set_key "borba_ssh_github_private_key" "$(jq -Rs . < "$HOME/.ssh/id_ed25519_github")"
  set_key "borba_ssh_github_public_key"  "$(jq -Rs . < "$HOME/.ssh/id_ed25519_github.pub")"
  set_key "ssh_host_ed25519_key"         "$(sudo jq -Rs . < "$host_key_path")"

  chmod 600 "$secrets_file"
  echo "Secrets file updated (existing unrelated keys preserved): $secrets_file"
fi

# ----- Verification -----
echo
echo "Verifying structure (keys should be at the top level, no 'data:' wrapper):"
sops -d "$secrets_file" | grep -E '^[a-z_]+:' || true

cat <<EOF

Next step:
  sudo nixos-rebuild switch --flake .#$host
EOF
