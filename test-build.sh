#!/usr/bin/env bash
set -e
cd /workspaces/nixos-config
nix build .#nixosConfigurations.macbook.config.system.build.nixos-rebuild --no-link
echo "Build succeeded!"
