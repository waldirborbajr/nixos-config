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
  boot.kernelParams = [ "mitigations=off" ]; # melhora performance em VMs

  # Melhor suporte a QEMU/UTM
  services.qemuGuest.enable = true;

  # ==================== PACOTES ESPECÍFICOS PARA ESTA MÁQUINA ====================
  environment.systemPackages = with pkgs; [
      # ===== Shell & CLI utilities =====
      wget
      curl
      zsh
      # fish
      # starship
      # atuin
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
      psmisc # provides killall
      coreutils
      fastfetch
      asciinema
      stow

      # ===== System monitoring & process management =====
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

      # ===== Terminal emulator =====
      alacritty

      # ===== Window manager / desktop utilities (i3) =====
      feh
      dex
      picom
      rofi
      lxappearance # customize i3 without changing config
      lxsession # provides lxpolkit
      autorandr # auto select a display configuration based on connected devices
      xkill
      xclip

      # ===== Hardware control =====
      brightnessctl
      playerctl
      pciutils

      # ===== Networking =====
      pkgs.networkmanagerapplet
      bluez

      # ===== Audio =====
      pulseaudio
      pavucontrol

      # ===== Media / video =====
      ffmpeg

      # ===== Virtualization / containers =====
      docker

      # ===== Hardware-specific tools =====
      chirp

      # ===== Compilers & build tools =====
      gcc
      glibc
      libcxx
      libgcc
      gdb
      cmake
      gnumake

      #     discord
      #     brave
      #     chromium
      #     flameshot
      #     yubikey-agent
      #     keepassxc
      #     xss-lock
      #     lolcat
      #     element-web
      #     zed-editor
      # # emacs deps
      # # make packages available to emacsclient (see nixos wiki's emacs docs)
      #     libvterm
      #     libtool
      #     pam_u2f
      #     ispell
      # # yak shaving
      # # update bios as needed
      #     fwupd
      # # content
      #     kdePackages.kdenlive
      #     obs-studio
      #     mesa # OpenCL for graphics x Davinci on Linux

      # ===== Helix language servers / formatters =====
      # Go (gopls already in the list)
      gotools # goimports
      golangci-lint-langserver

      # Rust (rust-analyzer/rustfmt via rustup are inconsistent in PATH;
      # prefer the nixpkgs packages below instead of relying on the rustup toolchain)
      rust-analyzer
      rustfmt

      # Lua
      lua-language-server
      stylua

      # TypeScript / JavaScript
      #nodePackages.typescript-language-server
      #nodePackages.typescript          # provides support for the internal tsserver
      #nodePackages.prettier

      # Python
      python3Packages.python-lsp-server # command: pylsp
      black

      # TOML
      taplo

      # JSON / JSONC
      #nodePackages.vscode-langservers-extracted  # provides vscode-json-language-server

      # YAML
      #nodePackages.yaml-language-server

      # XML
      lemminx

      # Nix
      nixd
      alejandra

      # Dockerfile
      #nodePackages.dockerfile-language-server-nodejs  # command: docker-langserver

      # Markdown
      marksman

      # Bash
      #nodePackages.bash-language-server
  ];

  # Programas opcionais (usando mkDefault por segurança)
  programs.firefox.enable = lib.mkDefault true;

  # Se quiser pacotes do unstable específicos desta máquina:
   environment.systemPackages = with pkgs-unstable; [
     neovim
   ];
}
