{ config, pkgs, lib, ... }:

{
  hardware.enableRedistributableFirmware = true;
  networking.networkmanager.enable = true;

  hardware.firmware = with pkgs; [
    broadcom-bt-firmware
    broadcom_sta
  ];

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pipewire.enable = true;

  services.upower.enable = true;
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services.tlp.enable = true;

  # EFI specific
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
}
