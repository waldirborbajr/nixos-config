# home/modules/tmux.nix
#
# Só tmux: lê a config de home/configs/tmux/tmux.conf (TPM, tema, binds)
# e o script de devshell. Todo o conteúdo do tmux vem do arquivo, não daqui.
{pkgs, ...}: let
  configs = ../configs;
  repoRoot = ../../.;
in {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile "${configs}/tmux/tmux.conf";
  };

  home.file.".local/bin/tmux-devshell" = {
    source = "${repoRoot}/scripts/tmux-devshell.sh";
    executable = true;
  };
}
