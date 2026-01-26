#!/bin/bash
# Quick Nix installation script for GitHub Codespaces
# Run with: bash install-nix.sh

set -e

echo "🚀 Installing Nix in GitHub Codespace..."
echo ""

# Check if Nix is already installed
if command -v nix &> /dev/null; then
    echo "✅ Nix is already installed!"
    nix --version
    exit 0
fi

# Install Nix in single-user mode (no sudo required)
echo "📦 Downloading and installing Nix..."
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Source Nix profile
echo ""
echo "⚙️  Configuring Nix environment..."
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Configure Nix with flakes support
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
max-jobs = auto
cores = 0
EOF

# Add Nix to bash profile if not already there
if ! grep -q "nix-profile/etc/profile.d/nix.sh" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Nix" >> ~/.bashrc
    echo 'if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then . ~/.nix-profile/etc/profile.d/nix.sh; fi' >> ~/.bashrc
fi

# Reload the shell configuration
source ~/.bashrc || true

echo ""
echo "✅ Nix installation complete!"
echo ""
echo "🔄 Please run one of these commands to activate Nix in this session:"
echo "   source ~/.nix-profile/etc/profile.d/nix.sh"
echo "   # or"
echo "   source ~/.bashrc"
echo ""
echo "Then verify with:"
echo "   nix --version"
echo ""
echo "📚 Available devshells after activation:"
echo "   nix flake show"
echo "   nix develop .#rust"
echo "   nix develop .#go"
echo "   nix develop .#postgresql"
echo ""
