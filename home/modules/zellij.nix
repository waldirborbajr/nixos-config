# home/modules/zellij.nix
#
# Só zellij: o pacote, a config (home/configs/zellij) e o script de devshell.
{pkgs, ...}: let
  configs = ../configs;
  repoRoot = ../../.;
in {
  home.packages = [pkgs.zellij];

  home.file.".local/bin/zellij-devshell" = {
    source = "${repoRoot}/scripts/zellij-devshell.sh";
    executable = true;
  };

  xdg.configFile."zellij" = {
    source = "${configs}/zellij";
    recursive = true;
  };
}
