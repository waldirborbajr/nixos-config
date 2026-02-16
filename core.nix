# core.nix
# Minimal core imports - profiles handle most configuration
# This file should only contain absolute essentials that every host needs
{ ... }:
{
  imports = [
    # Theme (centralized)
    ./modules/home/themes

    # Features on-demand (devops tools, qemu, tailscale)
    ./modules/core/features/devops.nix
    ./modules/core/features/qemu.nix
    ./modules/core/features/tailscale.nix

    # XDG portal (system services)
    ./modules/core/xdg-portal.nix
  ];
}
