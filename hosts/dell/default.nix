{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  ############################################
  # Host
  ############################################
  networking.hostName = "dell";

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = false;
    timeout = 2;
  };

  ############################################
  # Kernel (compatível com Broadcom WL)
  ############################################
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  ############################################
  # Wi-Fi — Broadcom BCM4315 [14e4:4315]
  ############################################
  nixpkgs.config.allowUnfree = true;

  boot.extraModulePackages = [
    pkgs.linuxPackages_6_6.broadcom_wl
  ];

  boot.kernelModules = [ "wl" ];

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "ssb"
    "brcmsmac"
    "iwlwifi"
  ];

  ############################################
  # CPU / Power
  ############################################
  powerManagement.cpuFreqGovernor = "schedutil";

  ############################################
  # Input
  ############################################
  services.libinput.enable = true;

  ############################################
  # Keyboard
  ############################################
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  ############################################
  # RTC
  ############################################
  time.hardwareClockInLocalTime = false;

  ############################################
  # I/O Scheduler
  ############################################
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';
}
