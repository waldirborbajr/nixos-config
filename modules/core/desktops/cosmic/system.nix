# modules/desktops/cosmic/system.nix
# System-level COSMIC configuration for GDM session selector
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.xserver.enable = true;

  services.displayManager.gdm = {
    enable = lib.mkDefault true;
    wayland = lib.mkDefault true;
  };

  services.desktopManager.cosmic.enable = true;

  # Portal support for COSMIC apps
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-cosmic
  ];

  environment.systemPackages = with pkgs; [
    cosmic-player
    cosmic-reader
    cosmic-wallpapers
    cosmic-ext-ctl
    cosmic-ext-applet-caffeine
    cosmic-ext-applet-external-monitor-brightness
    cosmic-ext-applet-minimon
    cosmic-ext-applet-privacy-indicator
    cosmic-ext-applet-sysinfo
    cosmic-ext-applet-weather
  ];
}
