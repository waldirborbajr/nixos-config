{ pkgs, ... }:

{
  imports = [
    ./git/default.nix
    ./gh/default.nix
    ./anydesk/default.nix
    ./alacritty/default.nix
    ./btop/default.nix
    ./zsh/default.nix
    ./go/default.nix
    ./rust/default.nix
    ./neovim/default.nix
    ./tmux/default.nix
    ./k8s/default.nix
  ];

  home.stateVersion = "25.11";

  programs.zsh.enable = true;
}

