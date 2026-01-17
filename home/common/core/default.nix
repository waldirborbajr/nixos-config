{ pkgs, ... }:

{
  imports = [
    ./btop/default.nix
    ./comitizen/default.nix
    ./eza/default.nix
    ./gh/default.nix
    ./git/default.nix
    ./lazygit/default.nix
    ./tmux/default.nix
    ./xdg/default.nix
    ./yazi/default.nix
    ./zsh/default.nix
  ];

}

