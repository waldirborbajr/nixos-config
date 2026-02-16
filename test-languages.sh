#!/usr/bin/env bash
# Test script to verify GO and Rust are available after rebuild

set -euo pipefail

echo "========================================="
echo "Testing Language Availability"
echo "========================================="
echo ""

# Check if commands exist
check_command() {
    local cmd="$1"
    local name="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✓ $name: $(command -v "$cmd")"
        "$cmd" --version 2>/dev/null | head -n 1 || echo "  (version check unavailable)"
    else
        echo "✗ $name: NOT FOUND"
        return 1
    fi
}

echo "GO Tools:"
check_command go "Go Compiler"
check_command gopls "Go LSP"
check_command gofumpt "Go Formatter"
check_command golangci-lint "Go Linter"
echo ""

echo "Rust Tools:"
check_command rustup "Rustup"
check_command cargo "Cargo"
check_command rustc "Rust Compiler" || true
check_command rust-analyzer "Rust Analyzer" || true
echo ""

echo "Environment Variables:"
echo "GOPATH: ${GOPATH:-NOT SET}"
echo "GOBIN: ${GOBIN:-NOT SET}"
echo ""

echo "========================================="
if command -v go >/dev/null 2>&1 && command -v cargo >/dev/null 2>&1; then
    echo "✓ Both GO and Rust are available!"
    exit 0
else
    echo "✗ Some tools are missing"
    echo ""
    echo "After running 'just switch macbook' (or appropriate host),"
    echo "you may need to:"
    echo "  1. Log out and log back in (to refresh environment)"
    echo "  2. For Rust: Run 'rustup default stable' if first time"
    exit 1
fi
