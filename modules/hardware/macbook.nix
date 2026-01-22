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
    linuxPkgs.b43-fwcutter  # se precisar
    linuxPkgs.broadcom-sta   # driver proprietário
    wirelesstools
    rfkill
  ];
}
