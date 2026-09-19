# home/modules/shell.nix
#
# ZDOTDIR layout do zsh, direnv e capacidades do terminal.
#
# zoxide / eza / fzf: binários partilhados por todos os hosts via HM.
# A init do zoxide continua em home/configs/zsh/zoxide.zsh (não usar
# programs.zoxide.enable para não duplicar o eval).
#
# EDITOR/VISUAL não ficam mais fixos aqui — vêm de home/modules/editors.nix,
# calculados dinamicamente a partir de qual editor está ligado.
{pkgs, ...}: let
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

  # Navegação / listagem / fuzzy — usados pelos dotfiles em configs/zsh/
  home.packages = with pkgs; [
    zoxide
    eza
    fzf
  ];

  # Suporte a cor de 24-bit no terminal — usado por qualquer coisa no
  # shell (fzf, bat, delta, prompts), não é específico de nenhum editor.
  home.sessionVariables.COLORTERM = "truecolor";
}
