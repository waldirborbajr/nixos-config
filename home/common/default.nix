{ pkgs, ... }:

{
  imports = [
    ./git/default.nix
    ./alacritty/default.nix
    ./btop/default.nix
    ./tmux/default.nix
    # ./zsh.nix
    # ./neovim.nix
    # ./tmux.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    go
    rustup
    neovim
    lazygit
    gh
  ];

  programs.zsh.enable = true;
}

