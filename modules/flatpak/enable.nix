{ config, pkgs, lib, ... }:

{
  ##########################################
  # Flatpak
  ##########################################

  services.flatpak.enable = true;

  # Add Flathub (system-wide)
  services.flatpak.remotes = lib.mkBefore [
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  ##########################################
  # XDG Portal
  ##########################################

  xdg.portal.enable = true;

  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gtk
  ];
}
