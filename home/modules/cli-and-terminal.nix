# home/modules/cli-and-terminal.nix
#
# Multiplexers (tmux/zellij), terminal emulator (wezterm), git (+ delta
# como pager de diff) e ferramentas de CLI que precisam de arquivo de
# config extra (bat, btop, ripgrep, oh-my-posh, lazygit, atuin, yazi,
# jujutsu).
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
  programs.bat.enable = true;

  # Só liga o programa (garante o pacote `git` no PATH); a config em si
  # (user, core, pull, delta etc.) vem inteira do link "git" abaixo, não
  # de programs.git.settings/delta (que brigaria com o arquivo linkado).
  programs.git.enable = true;

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
  # com o xdg.configFile abaixo). Ferramentas de desenvolvimento compartilhadas
  # (como ripgrep) são fornecidas por modules/development/base.nix.
  #
  # jujutsu/lazyjj estavam soltos em environment.systemPackages por host —
  # movidos pra cá (config real deles, jujutsu.toml, só existia em
  # home/configs/jujutsu/ mas nunca era linkada em lugar nenhum).
  home.packages = with pkgs; [
    # wezterm
    alacritty
    zellij
    oh-my-posh
    atuin
    jujutsu
    lazyjj
    delta # binário `delta` — ative em home/configs/git/config (core.pager = delta)
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
    #
    # alacritty.toml é comum a Linux e macOS e faz `general.import` de
    # ~/.config/alacritty/os.toml. Esse arquivo NÃO vem do diretório
    # "alacritty" abaixo — é resolvido aqui via hostPlatform, então o
    # home-manager symlinka o os-linux.toml ou o os-macos.toml certo pra
    # cada host, sem qualquer `if` dentro do TOML (que não suporta).
    # `recursive = true` no bloco "alacritty" é o que permite essa entrada
    # separada coexistir dentro da mesma pasta ~/.config/alacritty.
    "alacritty" = {
      source = "${configs}/alacritty";
      recursive = true;
    };
    "alacritty/os.toml".source =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "${configs}/alacritty-os/macos.toml"
      else "${configs}/alacritty-os/linux.toml";

    # "wezterm" = {
    #   source = "${configs}/wezterm";
    #   recursive = true;
    # };

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

    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };

    "git" = {
      source = "${configs}/git";
      recursive = true;
    };

    # jj procura em $XDG_CONFIG_HOME/jj/config.toml — não em
    # "jujutsu/", que é só o nome da pasta em home/configs/.
    "jj/config.toml" = {
      source = "${configs}/jujutsu/jujutsu.toml";
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
