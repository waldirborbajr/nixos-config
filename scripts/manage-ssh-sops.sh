#!/usr/bin/env bash
set -euo pipefail

case "${1:-$(hostname)}" in
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
    host="${1:-$(hostname)}"
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
secrets_file="$repo_root/hosts/$host/secrets/$host.yaml"

if [[ ! -d "$repo_root/hosts/$host" ]]; then
  echo "Host directory not found: $repo_root/hosts/$host" >&2
  exit 1
fi

mkdir -p "$HOME/.ssh" "$HOME/.config/sops/age"

for tool in ssh-keygen age-keygen sops; do
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
tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

{
  echo "borba_ssh_infra_private_key: |"
  sed 's/^/  /' "$HOME/.ssh/id_ed25519_infra"
  echo
  echo "borba_ssh_infra_public_key: $(cat "$HOME/.ssh/id_ed25519_infra.pub")"
  echo "borba_ssh_github_private_key: |"
  sed 's/^/  /' "$HOME/.ssh/id_ed25519_github"
  echo
  echo "borba_ssh_github_public_key: $(cat "$HOME/.ssh/id_ed25519_github.pub")"
} > "$tmp_file"

sops --encrypt --age "$age_recipient" --output-type yaml "$tmp_file" > "$secrets_file"
chmod 600 "$secrets_file"

cat <<EOF
SSH keys synchronized to SOPS file:
  $secrets_file

Next step:
  sudo nixos-rebuild switch --flake .#$host
EOF
