# home/modules/shell.nix
#
# ZDOTDIR layout do zsh, direnv e a sessionVariable de editor padrão.
# Extraído 1:1 de home/default.nix (split cirúrgico, sem mudança de
# comportamento).
{...}: let
  configs = ../configs;
in {
  # .zshenv must live outside ZDOTDIR.
  home.file.".zshenv".source = "${configs}/zshenv";

  # ZDOTDIR contents (everything except the zshenv file itself)
  xdg.configFile."zsh" = {
    source = "${configs}/zsh";
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    # Content comes from the ZDOTDIR tree; do not let HM emit its own .zshrc.
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # Editor padrão da sessão — única fonte de verdade agora (antes também
  # estava em modules/nixos/packages.nix como environment.variables;
  # removido de lá porque isso é preferência de usuário, não algo que
  # outras contas da máquina precisem herdar).
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
