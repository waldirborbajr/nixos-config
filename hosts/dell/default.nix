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
  # Wi-Fi — Broadcom BCM4315 [14e4:4315]
  ############################################
  # Driver proprietário (wl) — mais estável
  nixpkgs.config.allowUnfree = true;

  hardware.broadcom.wl.enable = true;

  boot.kernelModules = [ "wl" ];

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "ssb"
    "brcmsmac"
    "iwlwifi"
  ];

  ############################################
  # Kernel (compatível com wl)
  ############################################
  # Broadcom wl é mais estável aqui
  boot.kernelPackages = pkgs.linuxPackages_6_6;

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
  # I/O Scheduler (SSD / HDD)
  ############################################
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';
}
