# home/modules/cli-and-terminal.nix
#
# Multiplexers (zellij) e bat.
# atuin → home/modules/atuin.nix
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
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };
  };
}
