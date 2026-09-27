# home/modules/cli-and-terminal.nix
#
# Multiplexers (zellij), CLI tools com config extra (bat, lazygit, atuin,
# jujutsu, oh-my-posh). Identidade/git ficam em home/profiles/base.nix.
#
# Migrados para módulos próprios (NÃO declarar de novo aqui):
#   alacritty → home/modules/alacritty.nix  (programs.alacritty)
#   yazi      → home/modules/yazi.nix       (programs.yazi)
#   tmux      → home/modules/tmux.nix
#   btop      → home/modules/btop.nix
#   ripgrep   → home/modules/ripgrep.nix
#   zsh       → home/modules/zsh.nix / shell.nix
#
# Fonte ÚNICA dos binários + configs restantes: este módulo é importado
# por todos os hosts. Não declarar estes pacotes em environment.systemPackages.
{
  lib,
  config,
  pkgs,
  ...
}: let
  configs = ../configs;
  repoRoot = ../../.;
in {
  programs.lazygit.enable = true;
  programs.bat.enable = true;
  # yazi → home/modules/yazi.nix (não duplicar programs.yazi.enable aqui)

  # nh — wrapper pra nixos-rebuild / home-manager switch
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
    oh-my-posh
    atuin
    jujutsu
    lazyjj
    delta # binário — ative em home/configs/git/config (core.pager = delta)
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
    # alacritty → home/modules/alacritty.nix (programs.alacritty.settings)
    # yazi      → home/modules/yazi.nix
    # ripgrep   → home/modules/ripgrep.nix (programs.ripgrep.arguments)
    # tmux/btop → módulos próprios

    "zellij" = {
      source = "${configs}/zellij";
      recursive = true;
    };

    # oh-my-posh.old — pasta renomeada; apontar pro .old até migrar o módulo
    "oh-my-posh" = {
      source = "${configs}/oh-my-posh.old";
      recursive = true;
    };

    "lazygit" = {
      source = "${configs}/lazygit";
      recursive = true;
    };

    "fastfetch" = {
      source = "${configs}/fastfetch";
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

    # jj procura em $XDG_CONFIG_HOME/jj/config.toml
    "jj/config.toml" = {
      source = "${configs}/jujutsu/jujutsu.toml";
    };
  };

  # oh-my-posh grava init script em ~/.cache com path do store —
  # limpar em toda ativação evita prompt quebrado após rebuild.
  home.activation.clearOhMyPoshCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "${config.xdg.cacheHome}/oh-my-posh"
  '';
}
