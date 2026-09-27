# home/modules/cli-and-terminal.nix
#
# Multiplexers (zellij) e CLI tools restantes (bat, atuin).
#
# Migrados para módulos próprios (NÃO declarar de novo aqui):
#   alacritty → home/modules/alacritty.nix
#   yazi      → home/modules/yazi.nix
#   tmux      → home/modules/tmux.nix
#   btop      → home/modules/btop.nix
#   ripgrep   → home/modules/ripgrep.nix
#   zsh       → home/modules/zsh.nix / shell.nix
#   git / delta / gh / lazygit → home/modules/git.nix
#   jujutsu / lazyjj           → home/modules/jujutsu.nix
#   fastfetch → home/modules/fastfetch.nix
#   oh-my-posh → home/modules/oh-my-posh.nix
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
