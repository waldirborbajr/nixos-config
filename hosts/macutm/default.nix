# hosts/m2utm/default.nix
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: {
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
  boot.kernelParams = ["mitigations=off"];

  # Melhor suporte a QEMU/UTM
  services.qemuGuest.enable = true;

  # ==================== PACOTES PARA ESTA MÁQUINA ====================
  environment.systemPackages = with pkgs;
    [
      # Pacotes extras (não presentes no configuration.nix base)
      zellij
      
      yazi
      jq
      just
      duf
      psmisc
      asciinema
      stow
      lazygit
      jujutsu
      lazyjj
      emacs
      emacsPackages.pbcopy
      emacsPackages.vterm
      dex
      lxsession
      autorandr
      xkill
      brightnessctl
      playerctl
      pciutils
      pavucontrol
      ffmpeg
      docker
      gcc
      gnumake
      cmake
      gdb
      glibc
      libcxx
      libgcc
      chirp

      # Language servers e ferramentas de dev
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
      marksman
    ]
    ++ (with pkgs-unstable; [
      # Pacotes unstable específicos desta máquina
      neovim
    ]);

  # Programas opcionais
  programs.firefox.enable = lib.mkDefault true;
}
