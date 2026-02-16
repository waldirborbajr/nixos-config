# modules/apps/remote.nix
# Remote access tools (AnyDesk, etc.)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.remote.enable {
    # Install AnyDesk as a regular GUI application
    # No system service needed - it runs on-demand
    home.packages = with pkgs; [
      anydesk
    ];
  };
}
