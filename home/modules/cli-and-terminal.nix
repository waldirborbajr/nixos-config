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
  repoRoot = ../..;
in {
  # Módulos nativos do HM — instalam o binário; a config fica no xdg abaixo.
  programs.tmux.enable = true;
  programs.btop.enable = true;
  programs.lazygit.enable = true;
  programs.yazi.enable = true;

  # nh — wrapper mais amigável pra nixos-rebuild / home-manager switch /
  # nix-collect-garbage, com diff bonito das mudanças (via nvd) e output
  # via nix-output-monitor. `flake` aponta pro clone local do repo
  # (mesmo caminho que nixos-manager.sh usa/espera em todo host), então
  # `nh os switch` e `nh home switch` funcionam sem precisar passar
  # --flake toda vez.
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nixos-config";
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };

  # Pacotes sem módulo HM (ou cujo módulo geraria config própria em conflito
  # com o xdg.configFile abaixo). Só o binário — config via xdg.
  home.packages = with pkgs; [
    wezterm
    zellij
    ripgrep
    oh-my-posh
    atuin
  ];

  # tmux-devshell / zellij-devshell viram comando de verdade em qualquer
  # lugar (ex: dentro de $HOME/prj/algo), não só rodando ./script.sh da
  # raiz do nixos-config. $HOME/.local/bin já está no PATH via
  # home/configs/zshenv. O arquivo fonte continua sendo o da raiz do
  # repo — ./tmux-devshell.sh e ./zellij-devshell.sh continuam funcionando
  # normalmente pra quem preferir rodar direto de dentro do repo.
  home.file = {
    ".local/bin/tmux-devshell" = {
      source = "${repoRoot}/tmux-devshell.sh";
      executable = true;
    };
    ".local/bin/zellij-devshell" = {
      source = "${repoRoot}/zellij-devshell.sh";
      executable = true;
    };
  };

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

    "yazi" = {
      source = "${configs}/yazi";
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
  };

  # oh-my-posh grava o init script em ~/.cache/oh-my-posh com o caminho
  # absoluto do binário no Nix store. Depois de um rebuild esse path muda
  # e o cache antigo quebra o prompt (só aparece em hosts que rebuildaram).
  # Limpar em toda ativação garante que o próximo shell regenere o init.
  home.activation.clearOhMyPoshCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "${config.xdg.cacheHome}/oh-my-posh"
  '';
}
