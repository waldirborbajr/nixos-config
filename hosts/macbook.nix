# hosts/macbook.nix
# ---
{ config, pkgs, lib, ... }:

{
  system.stateVersion = "25.11";

  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../modules/nixpkgs.nix
    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix
    ../hardware-configuration-macbook.nix

    # Desktop apenas no MacBook
    ../modules/desktops/hyprland/default.nix
    ../modules/desktops/gnome.nix
    ../modules/autologin.nix
  ];

  ############################################
  # Host identity
  ############################################
  networking.hostName = "macbook-nixos";

  ############################################
  # Docker ON no MacBook (DevOps)
  ############################################
  virtualisation.docker.enable = lib.mkForce true;

  ############################################
  # GNOME services (safe)
  # - Keyring is useful even in Hyprland (browsers, git creds, ssh agents)
  # - Avoid enabling extra GNOME-only services here
  ############################################
  services.gnome.gnome-keyring.enable = true;

  ############################################
  # Bootloader (EFI)
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  # Keyboard layout
  ############################################
  console.keyMap = "us";

  ############################################
  # X11 layout (needed for GDM / GNOME selection screen)
  ############################################
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  ############################################
  # Permitir pacote Broadcom STA inseguro
  ############################################
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-6.12.66"
  ];

  ############################################
  # Pacotes extras para Wi-Fi e debug
  ############################################
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools
    util-linux
    config.boot.kernelPackages.broadcom_sta
  ];
}
