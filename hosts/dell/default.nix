{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "dell";

  # Bootloader
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = false;
    timeout = 2;
  };

  # Kernel — 6.6 ainda costuma funcionar melhor com broadcom-sta do que kernels muito novos
  boot.kernelPackages = pkgs.linuxPackages_6_6;

  # Wi-Fi — Broadcom BCM4315 [14e4:4315]
  nixpkgs.config.allowUnfree = true;

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  boot.kernelModules = [ "wl" ];

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "ssb"
    "brcmsmac"
    "iwlwifi"   # só por garantia mesmo
  ];

  # CPU / Power
  powerManagement.cpuFreqGovernor = "schedutil";

  # Input
  services.libinput.enable = true;

  # Teclado BR
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  # RTC
  time.hardwareClockInLocalTime = false;

  # I/O Scheduler
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';
}
