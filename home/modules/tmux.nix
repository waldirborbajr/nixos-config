# home/modules/tmux.nix
#
# Só tmux: lê home/configs/tmux/tmux.conf (TPM, binds) e renderiza o tema
# pela paleta central (renderTheme, home/modules/theme.nix).
# e o script de devshell. Todo o conteúdo do tmux vem do arquivo, não daqui.
{renderTheme, ...}: let
  configs = ../configs;
  repoRoot = ../../.;
in {
  programs.tmux = {
    enable = true;
    extraConfig = renderTheme (builtins.readFile "${configs}/tmux/tmux.conf");
  };

  home.file.".local/bin/tmux-devshell" = {
    source = "${repoRoot}/scripts/tmux-devshell.sh";
    executable = true;
  };
}
