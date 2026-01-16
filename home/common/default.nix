{ pkgs, ... }:

{
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    go
    rustup
    neovim
    lazygit
    alacritty
    tmux
    git
    gh
  ];

  programs.zsh.enable = true;
}
