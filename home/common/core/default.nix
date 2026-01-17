{ pkgs, ... }:

{
  imports = [
    ./git/default.nix
    ./gh/default.nix
    ./btop/default.nix
    ./zsh/default.nix
    ./tmux/default.nix
    ./yazi/default.nix
    ./eza/default.nix
    ./xdg/default.nix
    ./lazygit/default.nix
  ];

}

