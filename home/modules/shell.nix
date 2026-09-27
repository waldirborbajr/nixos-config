# home/modules/shell.nix
#
# O que NÃO é zsh: direnv, binários de navegação/listagem/fuzzy e
# COLORTERM. Todo o zsh (env, aliases, plugins, init) vive em
# home/modules/zsh.nix — não duplicar programs.zsh / xdg.configFile."zsh"
# / home.file.".zshenv" aqui.
{pkgs, ...}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # eza / fzf usados pelos aliases e widgets do zsh.nix
  # zoxide → programs.zoxide no zsh.nix
  home.packages = with pkgs; [
    eza
    fzf
  ];

  # 24-bit color — fzf, bat, delta, prompts
  home.sessionVariables.COLORTERM = "truecolor";
}
