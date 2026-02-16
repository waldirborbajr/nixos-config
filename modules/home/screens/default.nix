# modules/apps/screens.nix
# Screen locking and display management tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.screens.enable {
    home.packages =
      with pkgs;
      [ ]
      ++ lib.optional config.apps.screens.hyprlock.enable hyprlock
      ++ lib.optional config.apps.screens.swaylock-effects.enable swaylock-effects;
  };
}
