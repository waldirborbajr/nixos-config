# modules/hardware/macbook.nix
{ pkgs, ... }:
let
  linuxPkgs = pkgs.linuxPackages;
in
{
  hardware.enableRedistributableFirmware = true;
  boot.blacklistedKernelModules = [
    "brcmsmac"
    "wl"
  ];
  # Driver proprietário Broadcom para Wi-Fi
  boot.extraModulePackages = with linuxPkgs; [
    broadcom_sta
  ];
  # Firmware para b43 (se necessário; broadcom_sta é prioritário)
  hardware.firmware = with pkgs; [
    b43Firmware_5_1_138
  ];
}
