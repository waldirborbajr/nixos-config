{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;

  services.blueman.enable = true;

  # Carrega os módulos corretos no initrd e kernel
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  ############################################
  # Pacotes essenciais
  ############################################
  environment.systemPackages = with pkgs; [
    linux-firmware   # contém firmware Broadcom e outros
    bluez            # CLI Bluetooth
    blueman          # GUI Bluetooth
    pciutils
    usbutils
    rfkill
  ];

  ############################################
  # Bootloader GRUB
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = false; # evita warnings de outros OS
}
