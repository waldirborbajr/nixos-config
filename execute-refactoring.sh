#!/usr/bin/env bash
# Complete setup - creates branch and runs refactoring

cd "$(dirname "$0")"

echo "═════════════════════════════════════════"
echo "  NixOS Config Module Refactoring"
echo "═════════════════════════════════════════"
echo ""

# Create wiprefact branch
echo "Creating wiprefact branch..."
git checkout -b wiprefact 2>/dev/null || git checkout wiprefact
echo "✅ On branch wiprefact"
echo ""

# Make scripts executable
chmod +x migrate-modules.sh update-imports.sh run-refactoring.sh

# Run refactoring
./run-refactoring.sh
