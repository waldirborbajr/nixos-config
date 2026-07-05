# hosts/m2utm/default.nix
# Specific configuration for the UTM virtual machine on Mac M2 (aarch64)
{ lib, pkgs, pkgs-unstable, common, ... }:

let
  # Inherit common variables from configuration.nix
  inherit (common) dotfilesDir dotfileConfigDir;

  # Dotfiles specific to this host (UTM only)
  dotfilePrograms = [
    "lazygit"
    "yazi"
    # Add more UTM-specific dotfiles here in the future
  ];

  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # ==================== BOOTLOADER ====================
  # EFI bootloader (correct for UTM VM)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==================== KEYBOARD ====================
  # US/Mac layout (best for Mac M2 + UTM)
  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # ==================== VM OPTIMIZATIONS ====================
  # Performance improvements for virtual machine
  boot.kernelParams = [ "mitigations=off" ];

  # Better QEMU/UTM guest support
  services.qemuGuest.enable = true;

  # ==================== PACKAGES SPECIFIC TO UTM ====================
  environment.systemPackages = with pkgs; [
    # Extra tools not present in the base configuration.nix
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

    # Editors and development
    emacs
    emacsPackages.pbcopy
    emacsPackages.vterm

    # Desktop utilities
    dex
    lxsession
    autorandr
    xkill

    # Hardware & multimedia
    brightnessctl
    playerctl
    pciutils
    pavucontrol
    ffmpeg

    # Virtualization & development tools
    docker
    gcc
    gnumake
    cmake
    gdb
    glibc
    libcxx
    libgcc
    chirp

    # Language servers and formatters
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
    # Unstable packages specific to this host
    neovim
  ]);

  # Optional programs
  programs.firefox.enable = lib.mkDefault true;

  # ==================== DOTFILES SPECIFIC TO THIS HOST ====================
  # Only symlink dotfiles that are specific to the UTM VM
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
