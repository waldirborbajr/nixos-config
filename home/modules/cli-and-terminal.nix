# home/modules/cli-and-terminal.nix
#
# Multiplexers (tmux/zellij), terminal emulator (wezterm) e ferramentas
# de CLI que precisam de arquivo de config extra (btop, ripgrep,
# oh-my-posh, lazygit, atuin). Extraído 1:1 de home/default.nix (split
# cirúrgico, sem mudança de comportamento).
{
  lib,
  config,
  ...
}: let
  configs = ../configs;
in {
  # Tmux — package + full conf file
  programs.tmux.enable = true;
programs.lazygit = {
    enable = true;
    # settings = { ... };  # opcional; se preferires manter o YAML, deixa o xdg.configFile
  };

  programs.yazi = {
    enable = true;
    # enableZshIntegration = true;  # se quiseres
  };

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
  # oh-my-posh grava o init script em ~/.cache/oh-my-posh com o caminho
  # absoluto do binário no Nix store. Depois de um rebuild esse path muda
  # e o cache antigo quebra o prompt (só aparece em hosts que rebuildaram).
  # Limpar em toda ativação garante que o próximo shell regenere o init.
  home.activation.clearOhMyPoshCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "${config.xdg.cacheHome}/oh-my-posh"
  '';
}
