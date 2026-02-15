# modules/apps/network-manager.nix
# NetworkManager applet for system tray networking
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.network-manager.enable {
    home.packages = with pkgs; [
      networkmanagerapplet
    ];
  };
}
