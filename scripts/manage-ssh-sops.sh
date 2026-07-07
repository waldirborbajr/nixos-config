#!/usr/bin/env bash
#
# ssh-keys-to-sops.sh — generates (if missing) SSH keys for infra/github and
# syncs them into the per-host SOPS secrets file.
#
# Usage:
#   ./ssh-keys-to-sops.sh            # uses current hostname
#   ./ssh-keys-to-sops.sh dell       # or dell1456
#   ./ssh-keys-to-sops.sh mac2011    # or mac, macbook2011
#   ./ssh-keys-to-sops.sh macutm     # or m2utm
#
# IMPORTANT: uses `sops set` to update individual keys in-place, so any other
# secret already present in the file (e.g. ssh_host_ed25519_key, added by the
# ssh-hostkey-bootstrap systemd service) is preserved, not wiped out.

set -euo pipefail

hostname_now="$(hostname)"
case "${1:-$hostname_now}" in
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
    host="${1:-$hostname_now}"
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets_file="$repo_root/hosts/$host/secrets/$host.yaml"

if [[ ! -d "$repo_root/hosts/$host" ]]; then
  echo "Host directory not found: $repo_root/hosts/$host" >&2
  exit 1
fi

mkdir -p "$HOME/.ssh" "$HOME/.config/sops/age"
chmod 700 "$HOME/.ssh"

for tool in ssh-keygen age-keygen sops jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "$tool not found" >&2
    exit 1
  fi
done

age_key_file="$HOME/.config/sops/age/keys.txt"
export SOPS_AGE_KEY_FILE="$age_key_file"

if [[ ! -f "$age_key_file" ]]; then
  age-keygen -o "$age_key_file" >/dev/null
  chmod 600 "$age_key_file"
fi

for kind in infra github; do
  key_path="$HOME/.ssh/id_ed25519_${kind}"
  if [[ ! -f "$key_path" ]]; then
    ssh-keygen -q -t ed25519 -C "${kind}@${host}" -N "" -f "$key_path"
  fi
done

age_recipient="$(age-keygen -y "$age_key_file")"

# If the encrypted secrets file doesn't exist yet, bootstrap it as an empty
# encrypted document first — `sops set` requires an existing valid sops file
# to update, it can't create one from nothing.
if [[ ! -f "$secrets_file" ]]; then
  echo "{}" | sops --encrypt --age "$age_recipient" --input-type json --output-type yaml /dev/stdin > "$secrets_file"
  chmod 600 "$secrets_file"
  echo "Created new empty secrets file: $secrets_file"
fi

# sops set expects a JSON-encoded value. jq -Rs turns raw file content
# (including newlines) into a single properly-escaped JSON string.
set_key() {
  local key="$1" value_json="$2"
  sops set "$secrets_file" "[\"${key}\"]" "$value_json"
}

set_key "borba_ssh_infra_private_key"  "$(jq -Rs . < "$HOME/.ssh/id_ed25519_infra")"
set_key "borba_ssh_infra_public_key"   "$(jq -Rs . < "$HOME/.ssh/id_ed25519_infra.pub")"
set_key "borba_ssh_github_private_key" "$(jq -Rs . < "$HOME/.ssh/id_ed25519_github")"
set_key "borba_ssh_github_public_key"  "$(jq -Rs . < "$HOME/.ssh/id_ed25519_github.pub")"

chmod 600 "$secrets_file"

cat <<EOF
SSH keys synchronized to SOPS file (existing unrelated secrets preserved):
  $secrets_file

Next step:
  sudo nixos-rebuild switch --flake .#$host
EOF
