{ pkgs, ... }:

{
  hardware.enableRedistributableFirmware = true;

  networking.enableB43Firmware = true;

  boot.blacklistedKernelModules = [
    "brcmsmac"
    "wl"
  ];

  environment.systemPackages = with pkgs; [
    b43-fwcutter
    broadcom-sta   # substitui b43-firmware-legacy
    wirelesstools
    rfkill
  ];
}
