#!/usr/bin/env bash
set -euo pipefail

echo "==> Sanity checks"

test -f configuration.nix
test -d modules
test -d profiles

tree -L 3 || true

echo "✔ Sanity checks passed"
