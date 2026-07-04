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
    # === Essenciais para VM ===
    alacritty
    rofi
    feh
    picom
    brightnessctl
    playerctl
    ffmpeg
    docker

    # === Desenvolvimento leve ===
    rust-analyzer
    rustfmt
    lua-language-server
    nixd
    alejandra
  ];

  # Programas opcionais (usando mkDefault por segurança)
  programs.firefox.enable = lib.mkDefault true;

  # Se quiser pacotes do unstable específicos desta máquina:
  # environment.systemPackages = with pkgs-unstable; [
  #   neovim
  # ];
}
