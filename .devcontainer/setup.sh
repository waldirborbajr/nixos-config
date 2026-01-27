#!/bin/bash
# DevContainer setup script for NixOS config development

set -e

echo "🚀 Setting up NixOS Config DevContainer..."

# Configure Nix
echo "⚙️  Configuring Nix with flakes support..."
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf <<EOF
experimental-features = nix-command flakes
max-jobs = auto
cores = 0
EOF

# Update Nix channels
echo "📦 Updating Nix channels..."
nix-channel --update || true

# Build flake inputs cache (optional but speeds up first use)
echo "🔨 Building flake metadata cache..."
nix flake metadata . || echo "⚠️  Flake metadata build skipped (not critical)"

# Install direnv for auto-activation of devshells
echo "🔧 Installing direnv..."
nix-env -iA nixpkgs.direnv nixpkgs.nix-direnv || true

# Configure direnv
mkdir -p ~/.config/direnv
cat > ~/.config/direnv/direnvrc <<'EOF'
source $HOME/.nix-profile/share/nix-direnv/direnvrc
EOF

# Add direnv hook to bash
if ! grep -q "direnv hook bash" ~/.bashrc; then
  echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
fi

echo ""
echo "✅ DevContainer setup complete!"
echo ""
echo "📚 Available devshells:"
echo "  nix develop .#rust         → Rust stable + DB clients"
echo "  nix develop .#rust-nightly → Rust nightly + DB clients"
echo "  nix develop .#go           → Go + DB clients"
echo "  nix develop .#lua          → Lua development"
echo "  nix develop .#nix-dev      → Nix tooling"
echo "  nix develop .#fullstack    → Rust + Go + Node"
echo ""
echo "  nix develop .#postgresql   → PostgreSQL + tools"
echo "  nix develop .#mariadb      → MariaDB + tools"
echo "  nix develop .#sqlite       → SQLite + tools"
echo "  nix develop .#databases    → All databases"
echo ""
echo "💡 Use 'nix flake show' to list all available outputs"
echo ""
