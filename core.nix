# core.nix
# Minimal core imports - profiles handle most configuration
# This file should only contain absolute essentials that every host needs
{ ... }:
{
  imports = [
    # Theme (centralized)
    ./modules/themes

    # Features on-demand (devops tools, qemu, tailscale)
    ./modules/features/devops.nix
    ./modules/features/qemu.nix
    ./modules/features/tailscale.nix

    # XDG portal (system services)
    ./modules/xdg-portal.nix
  ];
}
