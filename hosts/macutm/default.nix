# hosts/m2utm/default.nix
{ lib, pkgs, pkgs-unstable, ... }:

{
  # Bootloader - EFI (correto para VM no UTM)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keyboard - US/Mac (para Mac M2 + UTM)
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # Otimizações leves para VM
  boot.kernelParams = [ "mitigations=off" ];

  # Melhor suporte a QEMU/UTM
  services.qemuGuest.enable = true;

  # ==================== PACOTES PARA ESTA MÁQUINA ====================
  environment.systemPackages = with pkgs; [
    # ===== Shell & CLI utilities =====
    wget
    curl
    zsh
    oh-my-posh
    zellij
    tmux
    yazi
    eza
    bat
    ripgrep
    jq
    just
    duf
    psmisc
    coreutils
    fastfetch
    asciinema
    stow

    # ===== System monitoring =====
    btop
    htop

    # ===== Git & version control =====
    git
    gh
    lazygit
    jujutsu
    lazyjj

    # ===== Editors =====
    helix
    emacs
    emacsPackages.pbcopy
    emacsPackages.vterm

    # ===== Terminal & WM =====
    alacritty
    feh
    dex
    picom
    rofi
    lxappearance
    lxsession
    autorandr
    xkill
    xclip

    # ===== Hardware & Multimedia =====
    brightnessctl
    playerctl
    pciutils
    pulseaudio
    pavucontrol
    ffmpeg

    # ===== Virtualization =====
    docker

    # ===== Compilers & tools =====
    gcc
    gnumake
    cmake
    gdb
    glibc
    libcxx
    libgcc

    # ===== Language servers & formatters =====
    rust-analyzer
    rustfmt
    lua-language-server
    stylua
    gotools
    golangci-lint-langserver
    python3Packages.python-lsp-server
    black
    taplo
    lemminx
    nixd
    alejandra
    marksman

    # Hardware specific
    chirp
  ]
  ++ (with pkgs-unstable; [
    # Pacotes unstable específicos desta máquina
    neovim
  ]);

  # Programas opcionais
  programs.firefox.enable = lib.mkDefault true;
}
