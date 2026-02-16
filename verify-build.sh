#!/usr/bin/env bash
# Test build script
set -euo pipefail

echo "Testing NixOS configuration build..."
cd "$(dirname "$0")"

if nix build .#nixosConfigurations.macbook.config.system.build.nixos-rebuild --no-link; then
    echo "✓ Build successful!"
    exit 0
else
    echo "✗ Build failed"
    exit 1
fi
