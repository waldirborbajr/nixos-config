# home/modules/cli-and-terminal.nix
#
# Multiplexers (tmux/zellij), terminal emulator (wezterm) e ferramentas
# de CLI que precisam de arquivo de config extra (btop, ripgrep,
# oh-my-posh, lazygit, atuin). Extraído 1:1 de home/default.nix (split
# cirúrgico, sem mudança de comportamento).
{...}: let
  configs = ../configs;
in {
  # Tmux — package + full conf file
  programs.tmux.enable = true;

  # Btop
  programs.btop.enable = true;

  xdg.configFile = {
    # Terminals
    # "alacritty" = {
    #   source = "${configs}/alacritty";
    #   recursive = true;
    # };
    "wezterm" = {
      source = "${configs}/wezterm";
      recursive = true;
    };

    "zellij" = {
      source = "${configs}/zellij";
      recursive = true;
    };
    "tmux" = {
      source = "${configs}/tmux";
      recursive = true;
    };

    "btop" = {
      source = "${configs}/btop";
      recursive = true;
    };
    "ripgrep" = {
      source = "${configs}/ripgrep";
      recursive = true;
    };
    "oh-my-posh" = {
      source = "${configs}/oh-my-posh";
      recursive = true;
    };
    "lazygit" = {
      source = "${configs}/lazygit";
      recursive = true;
    };

    "atuin" = {
      source = "${configs}/atuin";
      recursive = true;
    };
  };
}
