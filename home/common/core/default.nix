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
    ./nix/default.nix
    ./neovim/default.nix
    ./tmux/default.nix
    ./k8s/default.nix
    ./yazi/default.nix
    ./eza/default.nix
  ];

}

