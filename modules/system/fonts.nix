# modules/fonts.nix
# ---
{ config, pkgs, lib, ... }:
{
  config = lib.mkIf config.system-config.fonts.enable {
    ############################################
    # Fonts
    ############################################
    fonts = {
      packages = with pkgs; [
        nerd-fonts.jetbrains-mono
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "JetBrainsMono Nerd Font" ];
        };
      };
    };
  };
}
