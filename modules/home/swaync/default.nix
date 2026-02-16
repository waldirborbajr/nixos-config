# modules/apps/swaync.nix
# SwayNC notification center
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.swaync.enable {
    home.packages = with pkgs; [
      swaynotificationcenter
    ];
  };
}
