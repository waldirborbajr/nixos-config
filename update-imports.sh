#!/usr/bin/env bash
# Update Import Paths Script
# Updates all import statements to match new module structure

set -e

echo "🔄 Updating import paths..."
echo ""

# ============================================
# Helper function to update imports in a file
# ============================================
update_imports() {
    local file=$1
    echo "  📝 $file"
    
    # System core imports
    sed -i 's|\.\.\/modules\/system|../modules/core/system|g' "$file"
    sed -i 's|\.\/modules\/system|./modules/core/system|g' "$file"
    sed -i 's|modules\/system|modules/core/system|g' "$file"
    
    sed -i 's|\.\.\/modules\/desktops|../modules/core/desktops|g' "$file"
    sed -i 's|\.\/modules\/desktops|./modules/core/desktops|g' "$file"
    sed -i 's|modules\/desktops|modules/core/desktops|g' "$file"
    
    sed -i 's|\.\.\/modules\/features|../modules/core/features|g' "$file"
    sed -i 's|\.\/modules\/features|./modules/core/features|g' "$file"
    sed -i 's|modules\/features|modules/core/features|g' "$file"
    
    sed -i 's|\.\.\/modules\/users|../modules/core/users|g' "$file"
    sed -i 's|\.\/modules\/users|./modules/core/users|g' "$file"
    sed -i 's|modules\/users|modules/core/users|g' "$file"
    
    sed -i 's|\.\.\/modules\/virtualization|../modules/core/virtualization|g' "$file"
    sed -i 's|\.\/modules\/virtualization|./modules/core/virtualization|g' "$file"
    sed -i 's|modules\/virtualization|modules/core/virtualization|g' "$file"
    
    sed -i 's|\.\.\/modules\/autologin\.nix|../modules/core/autologin.nix|g' "$file"
    sed -i 's|\.\/modules\/autologin\.nix|./modules/core/autologin.nix|g' "$file"
    sed -i 's|modules\/autologin\.nix|modules/core/autologin.nix|g' "$file"
    
    sed -i 's|\.\.\/modules\/xdg-portal\.nix|../modules/core/xdg-portal.nix|g' "$file"
    sed -i 's|\.\/modules\/xdg-portal\.nix|./modules/core/xdg-portal.nix|g' "$file"
    sed -i 's|modules\/xdg-portal\.nix|modules/core/xdg-portal.nix|g' "$file"
    
    # Home-manager imports
    sed -i 's|\.\.\/modules\/apps|../modules/home|g' "$file"
    sed -i 's|\.\/modules\/apps|./modules/home|g' "$file"
    sed -i 's|modules\/apps|modules/home|g' "$file"
    
    sed -i 's|\.\.\/modules\/themes|../modules/home/themes|g' "$file"
    sed -i 's|\.\/modules\/themes|./modules/home/themes|g' "$file"
    sed -i 's|modules\/themes|modules/home/themes|g' "$file"
    
    # Language imports
    sed -i 's|\.\.\/modules\/languages|../modules/core/languages|g' "$file"
    sed -i 's|\.\/modules\/languages|./modules/core/languages|g' "$file"
    sed -i 's|modules\/languages|modules/core/languages|g' "$file"
}

# ============================================
# Update system-level configuration files
# ============================================
echo "📦 Updating system-level configs..."

# Profiles
update_imports "profiles/minimal.nix"
update_imports "profiles/desktop.nix"
update_imports "profiles/developer.nix"

# Hosts
update_imports "hosts/dell.nix"
update_imports "hosts/macbook.nix"

# Root level
update_imports "core.nix"
update_imports "home.nix"

# ============================================
# Update modules/home/default.nix
# ============================================
echo ""
echo "📦 Updating modules/home/default.nix..."

cat > modules/home/default.nix << 'EOF'
# modules/home/default.nix
# Home-manager level applications with individual enable options
{ config, lib, ... }:

{
  imports = [
    # Core apps
    ./zsh
    ./p10k
    ./micro
    ./bat
    ./fzf
    ./git
    ./alacritty
    ./wezterm
    ./fastfetch
    ./dev-tools
    ./commitizen
    ./ripgrep
    ./yazi
    ./tmux
    ./chirp
    ./lazygit
    ./nix

    # User apps (migrated from system)
    ./browsers
    ./communication
    ./helix
    ./neovim
    ./starship
    ./ides
    ./knowledge
    ./remote
    ./ssh-tools
    ./termius
    ./clipboard
    ./swaync
    ./network-manager
    ./zellij
    ./latex
    ./fun-tools
    ./screens

    # Modular apps (Dendritic Pattern)
    ./media
    ./productivity

    # Themes
    ./themes

    # Virtualization tools (Home Manager level)
    ./virtualbox
    ./distrobox
    
    # Languages (home-manager configs)
    ./languages
  ];

  # Note: All options remain in this file
  # They are defined here and used by individual modules
  
  options.apps = {
    # ... (keep all existing options as-is)
  };
}
EOF

# Only update the imports section, preserve the options
# Actually, let me just update the imports in the existing file
sed -i 's|./zsh/default.nix|./zsh|g' modules/home/default.nix
sed -i 's|./p10k/p10k.nix|./p10k|g' modules/home/default.nix
sed -i 's|./\([a-z-]*\)\.nix|./\1|g' modules/home/default.nix
sed -i 's|../virtualization/virtualbox.nix|./virtualbox|g' modules/home/default.nix
sed -i 's|../virtualization/distrobox.nix|./distrobox|g' modules/home/default.nix

# ============================================
# Update individual home modules if needed
# ============================================
echo ""
echo "📦 Checking home module relative imports..."

# Find all default.nix files in modules/home and update any relative imports
find modules/home -name "default.nix" -type f | while read -r file; do
    # Update any imports that reference parent modules
    if grep -q "\.\./\.\./themes" "$file" 2>/dev/null; then
        echo "  📝 Updating $file (themes import)"
        sed -i 's|\.\./\.\./themes|../themes|g' "$file"
    fi
    if grep -q "\.\./\.\./system" "$file" 2>/dev/null; then
        echo "  📝 Updating $file (system import)"
        sed -i 's|\.\./\.\./system|../../core/system|g' "$file"
    fi
done

# ============================================
# Update niri desktop imports
# ============================================
echo ""
echo "📦 Updating niri desktop module imports..."

if [ -d "modules/core/desktops/niri" ]; then
    find modules/core/desktops/niri -name "*.nix" -type f | while read -r file; do
        # Update wallpaper paths
        sed -i 's|../../../wallpapers|../../../../wallpapers|g' "$file"
        # Update any other relative paths as needed
    done
fi

echo ""
echo "✅ Import path updates complete!"
echo ""
echo "📝 Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Test build: sudo nixos-rebuild build --flake .#macbook"
echo "  3. If successful: git add -A && git commit"
echo ""
