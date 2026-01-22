# modules/hardware/macbook.nix
{ pkgs, ... }:

let
  linuxPkgs = pkgs.linuxPackages;
in
{
  hardware.enableRedistributableFirmware = true;

  networking.enableB43Firmware = true;

  boot.blacklistedKernelModules = [
    "brcmsmac"
    "wl"
  ];

  environment.systemPackages = with pkgs; [
    linuxPkgs.b43-fwcutter  # Broadcom firmware tool
    linuxPkgs.broadcom-sta   # Proprietary driver
    wirelesstools
    rfkill
  ];
}
