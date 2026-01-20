{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth Dell
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  ############################################
  # Kernel Modules
  ############################################
  boot.initrd.kernelModules = [ "b43" "btusb" ];
  
  ############################################
  # Forçar firmware no initrd
  ############################################
  boot.initrd.extraFirmware = with pkgs.linuxFirmware; [
    b43/ucode15.fw
  ];

  ############################################
  # Pacote de firmware
  ############################################
  environment.systemPackages = with pkgs; [
    linuxFirmware
  ];
}
