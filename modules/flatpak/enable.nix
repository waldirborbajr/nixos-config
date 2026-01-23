# modules/flatpak/enable.nix
# ---
{ config, pkgs, lib, ... }:

{
  services.flatpak.enable = true;

  environment.systemPackages =
    lib.optionals config.services.flatpak.enable [
      pkgs.flatpak
    ];

  # NOTE:
  # Do NOT manage xdg.portal here.
  # The desktop (Hyprland/GNOME) modules own portal backends to avoid duplication.
}
