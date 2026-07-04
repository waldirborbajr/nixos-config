{ config, pkgs, ... }:

{
  ##########################################
  # Flatpak
  ##########################################

  services.flatpak.enable = true;

  ##########################################
  # XDG Portal (needed for Flatpak apps)
  ##########################################

  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}
