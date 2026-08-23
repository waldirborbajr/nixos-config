# home/modules/cli-and-terminal.nix
#
# Multiplexers (tmux/zellij), terminal emulator (wezterm) e ferramentas
# de CLI que precisam de arquivo de config extra (btop, ripgrep,
# oh-my-posh, lazygit, atuin, yazi).
#
# Fonte ÚNICA dos binários + configs: este módulo é importado por todos
# os hosts (Linux via home/default.nix, MacBook via hosts/macbook/home.nix).
# Não declarar estes pacotes em environment.systemPackages.
{
  lib,
  config,
  pkgs,
  ...
}: let
  configs = ../configs;
in {
  # Módulos nativos do HM — instalam o binário; a config fica no xdg abaixo.
  programs.tmux.enable = true;
  programs.btop.enable = true;
  programs.lazygit.enable = true;
  programs.yazi.enable = true;

  # Pacotes sem módulo HM (ou cujo módulo geraria config própria em conflito
  # com o xdg.configFile abaixo). Só o binário — config via xdg.
  home.packages = with pkgs; [
    wezterm
    zellij
    ripgrep
    oh-my-posh
    atuin
  ];

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
