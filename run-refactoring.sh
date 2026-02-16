#!/usr/bin/env bash
# Complete Refactoring Script - Runs everything in order

set -e

echo "═════════════════════════════════════════"
echo "  NixOS Config Module Refactoring"
echo "═════════════════════════════════════════"
echo ""

# Make scripts executable
chmod +x migrate-modules.sh
chmod +x update-imports.sh

# Step 1: Migrate modules
echo "Step 1: Migrating module files..."
echo "─────────────────────────────────────────"
./migrate-modules.sh

# Step 2: Update imports
echo ""
echo "Step 2: Updating import paths..."
echo "─────────────────────────────────────────"
./update-imports.sh

echo ""
echo "═════════════════════════════════════════"
echo "  ✅ Refactoring Complete!"
echo "═════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Review changes: git status && git diff"
echo "  2. Test build: sudo nixos-rebuild build --flake .#macbook"
echo "  3. If successful: git add -A && git commit -m 'refactor: reorganize modules into core/ and home/'"
echo ""
