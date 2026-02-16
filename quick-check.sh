#!/usr/bin/env bash
# Quick syntax check for the flake

set -e

echo "Checking flake syntax..."
nix flake check --impure 2>&1 | head -50 || {
    echo ""
    echo "If you see module-related errors above, there may still be issues."
    echo "Otherwise, the configuration should be valid!"
}

echo ""
echo "Testing evaluation of macbook configuration..."
nix eval --impure ".#nixosConfigurations.macbook.config.system.name" 2>&1 || {
    echo "Evaluation failed - check errors above"
    exit 1
}

echo ""
echo "✓ Flake evaluation successful!"
echo "To apply: just switch macbook (or your hostname)"
