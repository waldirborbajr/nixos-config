#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "=========================================="
echo "Testing NixOS configuration build..."
echo "Host: macbook"
echo "=========================================="
echo ""

nix build .#nixosConfigurations.macbook.config.system.build.nixos-rebuild --no-link

echo ""
echo "=========================================="
echo "✓ Build successful!"
echo "=========================================="
