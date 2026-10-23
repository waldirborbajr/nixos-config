# home/modules/tuios.nix
#
# Só tuios: o pacote e a config (home/configs/tuios).
{pkgs, ...}: let
  configs = ../configs;
in {
  home.packages = [pkgs.tuios];

  xdg.configFile."tuios" = {
    source = "${configs}/tuios";
    recursive = true;
  };
}
