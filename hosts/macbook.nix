# hosts/macbook.nix
{ config, pkgs, lib, ... }:

{
  ############################################
  # Hardware & Performance
  ############################################
  imports = [
    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix
    ../hardware-configuration-macbook.nix
  ];

  ############################################
  # Host identity
  ############################################
  networking.hostName = "macbook-nixos";

  ############################################
  # Bootloader (EFI)
  ############################################
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  ############################################
  # Keyboard layout
  ############################################
  console.keyMap = "us";

  services.xserver.enable = true;
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "";

  ############################################
  # System packages (wireless/debug tools)
  ############################################
  environment.systemPackages = with pkgs; [
    iw            # Wireless tools
    wirelesstools # iwconfig, ifconfig, etc.
  ];
}
