#!/usr/bin/env bash
set -euo pipefail

echo "==> Building NixOS system (no switch)"

nix-shell -p nixos-rebuild --run \
  "nixos-rebuild build \
     -I nixos-config=$(pwd)/configuration.nix \
     --dry-run"

echo "✔ Build succeeded"
