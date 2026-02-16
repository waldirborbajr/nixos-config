#!/usr/bin/env bash
# Evaluate language module configuration without building

set -euo pipefail

HOST="${1:-macbook}"

echo "========================================="
echo "Evaluating language configuration"
echo "Host: $HOST"
echo "========================================="
echo ""

echo "Checking flake syntax..."
if ! nix flake check --impure --all-systems 2>&1 | grep -E "(error|warning)" | head -20; then
    echo "✓ No errors/warnings found"
fi
echo ""

echo "Evaluating home-manager packages for languages..."
nix eval --impure ".#nixosConfigurations.${HOST}.config.home-manager.users.borba.home.packages" --apply 'pkgs: builtins.map (p: p.name or "unnamed") (builtins.filter (p: builtins.match ".*(go|rust|cargo|gopls).*" (p.name or "")) pkgs)' 2>/dev/null || {
    echo "Note: Could not directly eval packages (this is normal with current setup)"
    echo "Checking if flake builds without errors instead..."
    echo ""
}

echo "Attempting dry-run build to verify configuration..."
nix build --dry-run --impure ".#nixosConfigurations.${HOST}.config.system.build.toplevel" 2>&1 | tail -20

echo ""
echo "========================================="
echo "If no errors above, the configuration is valid!"
echo "To apply: just switch ${HOST}"
echo "========================================="
