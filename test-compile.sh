#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

echo "Testing NixOS configuration build for macbook..."
echo ""

if nix build .#nixosConfigurations.macbook.config.system.build.nixos-rebuild --no-link; then
    echo ""
    echo "✓ Build successful!"
    exit 0
else
    echo ""
    echo "✗ Build failed"
    exit 1
fi
