#!/usr/bin/env bash
# Module Refactoring Migration Script
# Moves modules from current structure to new core/home structure

set -e

echo "🔄 Starting module refactoring..."
echo ""

# Create base directories
echo "📁 Creating new directory structure..."
mkdir -p modules/core
mkdir -p modules/home

# ============================================
# SYSTEM CORE MODULES → modules/core/
# ============================================
echo ""
echo "📦 Moving system core modules..."

# Move system/
echo "  → modules/core/system/"
mv modules/system modules/core/

# Move desktops/
echo "  → modules/core/desktops/"
mv modules/desktops modules/core/

# Move features/
echo "  → modules/core/features/"
mv modules/features modules/core/

# Move users/
echo "  → modules/core/users/"
mv modules/users modules/core/

# Move standalone files
echo "  → modules/core/autologin.nix"
mv modules/autologin.nix modules/core/

echo "  → modules/core/xdg-portal.nix"
mv modules/xdg-portal.nix modules/core/

# Handle virtualization (split system vs home-manager)
echo "  → modules/core/virtualization/ (system-level only)"
mkdir -p modules/core/virtualization
mv modules/virtualization/docker.nix modules/core/virtualization/
mv modules/virtualization/podman.nix modules/core/virtualization/
mv modules/virtualization/k3s.nix modules/core/virtualization/
mv modules/virtualization/libvirt.nix modules/core/virtualization/
mv modules/virtualization/default.nix modules/core/virtualization/
mv modules/virtualization/README.md modules/core/virtualization/ 2>/dev/null || true

# Handle languages (split system vs home-manager)
echo "  → modules/core/languages/ (system-level)"
mkdir -p modules/core/languages
mv modules/languages/nodejs.nix modules/core/languages/
mv modules/languages/python.nix modules/core/languages/
mv modules/languages/go.nix modules/core/languages/
mv modules/languages/lua.nix modules/core/languages/
mv modules/languages/nix-dev.nix modules/core/languages/
mv modules/languages/rust.nix modules/core/languages/
mv modules/languages/default.nix modules/core/languages/

# ============================================
# HOME-MANAGER MODULES → modules/home/
# ============================================
echo ""
echo "📦 Moving home-manager modules..."

# Create main default.nix aggregator
echo "  → modules/home/default.nix"
mv modules/apps/default.nix modules/home/default.nix

# Move existing folders (keep structure)
echo "  → modules/home/zsh/"
mv modules/apps/zsh modules/home/

echo "  → modules/home/p10k/"
mv modules/apps/p10k modules/home/

echo "  → modules/home/media/"
mv modules/apps/media modules/home/

echo "  → modules/home/productivity/"
mv modules/apps/productivity modules/home/

# Move themes/
echo "  → modules/home/themes/"
mv modules/themes modules/home/

# Create folders for single-file modules
echo ""
echo "📁 Creating folders for single-file home modules..."

# Function to move .nix file to folder/default.nix
move_to_folder() {
    local src=$1
    local name=$(basename "$src" .nix)
    local dest="modules/home/$name"
    
    echo "  → $dest/"
    mkdir -p "$dest"
    mv "$src" "$dest/default.nix"
}

# Move all single .nix files from apps/
move_to_folder "modules/apps/alacritty.nix"
move_to_folder "modules/apps/bat.nix"
move_to_folder "modules/apps/browsers.nix"
move_to_folder "modules/apps/chirp.nix"
move_to_folder "modules/apps/clipboard.nix"
move_to_folder "modules/apps/commitizen.nix"
move_to_folder "modules/apps/communication.nix"
move_to_folder "modules/apps/dev-tools.nix"
move_to_folder "modules/apps/fastfetch.nix"
move_to_folder "modules/apps/fun-tools.nix"
move_to_folder "modules/apps/fzf.nix"
move_to_folder "modules/apps/git.nix"
move_to_folder "modules/apps/helix.nix"
move_to_folder "modules/apps/ides.nix"
move_to_folder "modules/apps/knowledge.nix"
move_to_folder "modules/apps/latex.nix"
move_to_folder "modules/apps/lazygit.nix"
move_to_folder "modules/apps/micro.nix"
move_to_folder "modules/apps/neovim.nix"
move_to_folder "modules/apps/network-manager.nix"
move_to_folder "modules/apps/nix.nix"
move_to_folder "modules/apps/remote.nix"
move_to_folder "modules/apps/ripgrep.nix"
move_to_folder "modules/apps/screens.nix"
move_to_folder "modules/apps/ssh-tools.nix"
move_to_folder "modules/apps/starship.nix"
move_to_folder "modules/apps/swaync.nix"
move_to_folder "modules/apps/termius.nix"
move_to_folder "modules/apps/tmux.nix"
move_to_folder "modules/apps/wezterm.nix"
move_to_folder "modules/apps/yazi.nix"
move_to_folder "modules/apps/zellij.nix"

# Move documentation files
echo ""
echo "📄 Moving documentation files..."
if [ -f "modules/apps/TMUX-KEYBINDINGS.md" ]; then
    mv modules/apps/TMUX-KEYBINDINGS.md modules/home/tmux/KEYBINDINGS.md
fi
if [ -f "modules/apps/WEZTERM-INFO.md" ]; then
    mv modules/apps/WEZTERM-INFO.md modules/home/wezterm/INFO.md
fi
if [ -f "modules/apps/YAZI-MIGRATION.md" ]; then
    mv modules/apps/YAZI-MIGRATION.md modules/home/yazi/MIGRATION.md
fi
if [ -f "modules/apps/config.jsonc" ]; then
    mv modules/apps/config.jsonc modules/home/config.jsonc
fi

# Handle home-manager language configs
echo ""
echo "📁 Creating modules/home/languages/"
mkdir -p modules/home/languages
if [ -f "modules/languages/nodejs-home.nix" ]; then
    mv modules/languages/nodejs-home.nix modules/home/languages/nodejs.nix
fi
if [ -f "modules/languages/python-home.nix" ]; then
    mv modules/languages/python-home.nix modules/home/languages/python.nix
fi

# Move virtualbox and distrobox (home-manager) Create folders
echo "  → modules/home/virtualbox/"
mkdir -p modules/home/virtualbox
if [ -f "modules/virtualization/virtualbox.nix" ]; then
    mv modules/virtualization/virtualbox.nix modules/home/virtualbox/default.nix
fi

echo "  → modules/home/distrobox/"
mkdir -p modules/home/distrobox
if [ -f "modules/virtualization/distrobox.nix" ]; then
    mv modules/virtualization/distrobox.nix modules/home/distrobox/default.nix
fi

# Remove old empty directories
echo ""
echo "🗑️  Removing old empty directories..."
rmdir modules/apps 2>/dev/null || echo "  (modules/apps not empty or already removed)"
rmdir modules/languages 2>/dev/null || echo "  (modules/languages not empty or already removed)"
rmdir modules/virtualization 2>/dev/null || echo "  (modules/virtualization not empty or already removed)"

echo ""
echo "✅ Module structure migration complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Run: ./update-imports.sh (to update all import paths)"
echo "  2. Test build: sudo nixos-rebuild build --flake .#macbook"
echo "  3. If successful: git add -A && git commit -m 'refactor: reorganize modules into core/ and home/'"
echo ""
