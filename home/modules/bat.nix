# home/modules/bat.nix
#
# bat sob controle do Home Manager.
# Tema Catppuccin Mocha + config (--theme, --plain).
#
# NÃO usar xdg.configFile."bat" nem programs.bat noutro módulo.
{pkgs, ...}: let
  catppuccinMochaTheme = pkgs.runCommand "bat-theme-catppuccin-mocha" {} ''
    mkdir -p $out
    cp ${./Catppuccin-Mocha.tmTheme} "$out/Catppuccin Mocha.tmTheme"
  '';
in {
  programs.bat = {
    enable = true;

    config = {
      theme = "Catppuccin Mocha";
      style = "plain";
    };

    themes = {
      "Catppuccin Mocha" = {
        src = catppuccinMochaTheme;
        file = "Catppuccin Mocha.tmTheme";
      };
    };
  };
}
