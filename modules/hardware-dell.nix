{ config, pkgs, lib, ... }:

{
  ############################################
  # Dell Inspiron 1564 — Broadcom BCM4312 LP-PHY
  ############################################

  ############################################
  # Firmware
  ############################################
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Network & Bluetooth
  ############################################
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  ############################################
  # Broadcom LP-PHY firmware (CORRETO)
  ############################################
  environment.systemPackages = with pkgs; [
    b43-firmware-legacy
    b43-fwcutter

    pciutils
    usbutils
    wirelesstools
    rfkill
  ];

  ############################################
  # Kernel modules — ORDEM IMPORTA
  ############################################

  # Initrd
  boot.initrd.kernelModules = [
    "ssb"
    "b43"
  ];

  # Runtime
  boot.kernelModules = [
    "ssb"
    "b43"
  ];

  ############################################
  # Blacklist — EVITA CONFLITO (CRÍTICO)
  ############################################
  boot.blacklistedKernelModules = [
    "bcma"
    "brcmsmac"
    "wl"
  ];

  ############################################
  # Bootloader (Dell legacy BIOS)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.devices = [ "/dev/sda" ];
}
