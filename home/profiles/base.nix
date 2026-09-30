# home/profiles/base.nix
#
# Perfil base do home-manager — vale para TODOS os hosts, incluindo o
# macbook (que não tem niri/desktop). Irmão de ./desktop.nix, não
# importado por ele (mesmo padrão do ulyssecrn/nixos-config) — cada
# host que precisa da camada gráfica importa os dois, lado a lado, no
# próprio home.nix.
#
# Nada aqui pode depender de sessão gráfica (terminal GUI, visualizador
# de PDF, gerenciador de arquivo GTK, etc.) — isso tudo mora em
# home/profiles/desktop.nix.
#
# Igual ao base.nix do ulyssecrn: tudo que é comum a qualquer host vive
# DIRETO aqui (identidade, pacotes utilitários sem config própria) —
# o que tem módulo/config dedicado entra via imports.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ../modules/shell.nix
    ../modules/editors.nix
    ../modules/cli-and-terminal.nix
    ../modules/btop.nix
    ../modules/tmux.nix
    ../modules/ripgrep.nix
    ../modules/fastfetch.nix
    ../modules/yazi.nix
    ../modules/zsh.nix
    ../modules/oh-my-posh.nix
    ../modules/git.nix
    ../modules/lazygit.nix
    ../modules/atuin.nix
    ../modules/jujutsu.nix
  ];

  # ── Identidade ──────────────────────────────────────────────────────
  home.username = "borba";
  home.homeDirectory = "/home/borba";

  xdg.enable = true;

  # nix-index-database + comma
  programs.nix-index-database.comma.enable = true;

  # ── Git ─────────────────────────────────────────────────────────────
  # ÚNICO dono: home/modules/git.nix
  # (home.file.".config/git/config" + packages: git, delta, gh, gh-dash, lazygit, …)
  # NÃO usar programs.git nem xdg.configFile."git" aqui.

  # ── Pacotes comuns (sem config própria) ──────────────────────────────
  # gh / gh-dash / delta / git → home/modules/git.nix
  # eza → home/modules/shell.nix
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    asciinema-scenario
    kdlfmt
    unzip
    unrar
    zip
    p7zip
    ffmpeg
    marksman

    # CLI tools (faltando vs. ulyssecrn/nixos-config)
    nmap
    which
    tree
    gawk
    yt-dlp
    traceroute
    dnsutils
    xz
    gnutar

    # Monitoring tools
    lm_sensors # sensors
    usbutils # lsusb
  ];

  # editors.emacs.enable = true;
  # editors.neovim.enable = true;

  home.stateVersion = "26.05";
}
