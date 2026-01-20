{ config, pkgs, lib, ... }:

{
  ############################################
  # Wi-Fi (Dell Inspiron)
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  # Firmware Broadcom b43
  hardware.firmware = [
    pkgs.firmware.b43
    pkgs.firmware.b43-open
  ];

  # Kernel modules para Broadcom
  boot.kernelModules = lib.mkDefault [
    "b43"
    "ssb"       # Broadcom support
    "bcma"
  ];

  ############################################
  # Bluetooth
  ############################################
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;

  ############################################
  # Audio (PipeWire)
  ############################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # Keyboard — Dell Inspiron (pt_BR)
  ############################################
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  ############################################
  # Bootloader (Legacy BIOS - Dell)
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };
}
