{ pkgs, ... }:

{
  imports = [
    ./git/default.nix
    ./alacritty/default.nix
    ./btop/default.nix
    ./zsh/default.nix
    ./go/default.nix
    ./rust/default.nix
    ./neovim/default.nix
    ./tmux/default.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    gh
  ];

  programs.zsh.enable = true;
}

