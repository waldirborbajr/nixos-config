#!/usr/bin/env bash
#
# backup-age-key.sh — displays this host's sops age private key in a
# copy-paste-friendly block, ready to store in a password manager.
#
# Root problem this solves: the age private key at
# ~/.config/sops/age/keys.txt is the ONLY thing that can decrypt this
# host's hosts/<host>/secrets/<host>.yaml. It is intentionally never
# committed to git. If the disk is wiped without a backup of this file,
# every secret encrypted for this host (SSH keys included) becomes
# permanently unrecoverable — even though the encrypted .yaml itself
# survives fine in git.
#
# Usage:
#   ./scripts/backup-age-key.sh
#
# This script does NOT write anything to disk or send anything over the
# network. It only prints the key (plus its public fingerprint, so you
# can verify you copied the right thing) so you can paste it manually
# into a password manager entry. Never commit this output, never paste
# it into a chat, issue tracker, or unencrypted file.

set -euo pipefail

age_key_file="$HOME/.config/sops/age/keys.txt"
hostname_now="$(hostname)"

if [[ ! -f "$age_key_file" ]]; then
  echo "No age key found at $age_key_file on this host ($hostname_now)." >&2
  echo "Nothing to back up yet — run manage-ssh-sops.sh first to generate one." >&2
  exit 1
fi

if ! command -v age-keygen >/dev/null 2>&1; then
  echo "age-keygen not found on PATH. Re-run this script inside a nix shell:" >&2
  echo "  nix --extra-experimental-features \"nix-command flakes\" shell nixpkgs#age -c $0" >&2
  exit 1
fi

public_key="$(age-keygen -y "$age_key_file")"

echo "=================================================================="
echo " AGE KEY BACKUP — host: $hostname_now"
echo "=================================================================="
echo
echo "Public key (for verification only — safe to share/commit):"
echo "  $public_key"
echo
echo "Private key file (SECRET — copy the entire block below into a"
echo "password manager entry named e.g. 'age-key-${hostname_now}'):"
echo
echo "------------------------- BEGIN age keys.txt -------------------------"
cat "$age_key_file"
echo "-------------------------- END age keys.txt ---------------------------"
echo
echo "Reminder:"
echo "  - Store ONLY in your password manager's secure-note feature."
echo "  - Never commit this to git, paste in chat, or save unencrypted."
echo "  - Repeat this on every host: macutm, dell1564, mac2011, macvmf."
