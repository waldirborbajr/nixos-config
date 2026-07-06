# hosts/m2utm/default.nix
# Specific configuration for the UTM virtual machine on Mac M2 (aarch64)
# This is the primary development environment: most powerful host, so it
# carries the heaviest toolchain (compilers, LSPs, dev CLIs).
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
  # Trade-off: disables CPU vulnerability mitigations (Spectre/Meltdown etc.)
  # for better performance. Acceptable here since this is an isolated UTM VM,
  # not exposed directly to untrusted workloads.
  boot.kernelParams = [ "mitigations=off" ];
  # Better QEMU/UTM guest support
  services.qemuGuest.enable = true;

  # ==================== PACKAGES SPECIFIC TO THIS HOST ====================
  environment.systemPackages = with pkgs; [
    # Terminal & shell utilities
    zellij
    yazi
    jq
    just
    duf
    psmisc
    asciinema

    # Version control
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

    # Virtualization & native toolchain
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

    # Only for LLM
    # llm-suggest-lsp
    # uwu-colors
    # simple-completion-language-server
  ];
  # NOTE: pkgs-unstable.neovim already comes from configuration.nix.
  # Not repeated here to avoid duplicate entries in systemPackages.

  # Optional programs
  programs.firefox.enable = lib.mkDefault true;

  # ==================== HOST-SPECIFIC DOTFILES ====================
  # Only symlink dotfiles specific to the UTM VM
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
