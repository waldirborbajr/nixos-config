{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  ############################################
  # Nixpkgs global config (unfree + insecure)
  ############################################
#  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.permittedInsecurePackages = [
#    "broadcom-sta-6.30.223.271"   # driver wl proprietário antigo, marcado como insecure
#  ];

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
  # Kernel (compatível com broadcom-sta)
  ############################################
  # Use 6.6 ou mais antigo — kernels novos (>6.10) frequentemente quebram a compilação
  boot.kernelPackages = pkgs.linuxPackages_6_6;   # ou teste linuxPackages_6_1 / linuxPackages_lts se falhar

  ############################################
  # Wi-Fi — Broadcom BCM4315 [14e4:4315]
  ############################################
 # boot.extraModulePackages = with config.boot.kernelPackages; [
 #   broadcom_sta
 # ];

  boot.kernelModules = [ "wl" ];

  boot.blacklistedKernelModules = [
    "b43"
    "bcma"
    "ssb"
    "brcmsmac"
    "iwlwifi"   # só por precaução
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
  # Keyboard (BR ABNT2)
  ############################################
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  ############################################
  # RTC (UTC recomendado para dual-boot)
  ############################################
  time.hardwareClockInLocalTime = false;

  ############################################
  # I/O Scheduler otimizado
  ############################################
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';

  # Opcional: habilita firmware non-free (pode ajudar em outros drivers)
  # hardware.enableAllFirmware = true;
}
