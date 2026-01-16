{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./alacritty.nix
    ./btop.nix
    ./tmux.nix
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

