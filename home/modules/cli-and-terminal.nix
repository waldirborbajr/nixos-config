# home/modules/cli-and-terminal.nix
#
# Multiplexers (zellij) e CLI tools restantes (bat, atuin).
# Tudo git/delta/gh/lazygit/jj/oh-my-posh/alacritty/yazi/tmux/zsh → módulos próprios.
{
  config,
  pkgs,
  ...
}: let
  configs = ../configs;
  repoRoot = ../../.;
in {
  programs.bat.enable = true;

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };

  home.packages = with pkgs; [
    zellij
    atuin
  ];

  home.file = {
    ".local/bin/tmux-devshell" = {
      source = "${repoRoot}/scripts/tmux-devshell.sh";
      executable = true;
    };
    ".local/bin/zellij-devshell" = {
      source = "${repoRoot}/scripts/zellij-devshell.sh";
      executable = true;
    };
  };

  xdg.configFile = {
    "zellij" = {
      source = "${configs}/zellij";
      recursive = true;
    };
    "atuin" = {
      source = "${configs}/atuin";
      recursive = true;
    };
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };
  };
}
