{ config, pkgs, lib, ... }:

{
  # Dell ACPI bug: mata Wi-Fi e Bluetooth
  boot.blacklistedKernelModules = [
    "dell_laptop"
    "dell_wmi"
    "dell_smbios"
  ];

  networking.enableB43Firmware = true;

  environment.systemPackages = with pkgs; [
    b43-fwcutter
    iw
    rfkill
  ];
}
