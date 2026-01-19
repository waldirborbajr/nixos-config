{ config, pkgs, lib, ... }:

{
  ############################################
  # Hardware profile — MacBook Pro 13" (2011)
  ############################################

  ############################################
  # Firmware (Broadcom Wi-Fi)
  ############################################
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Wi-Fi (Broadcom BCM4331)
  ############################################
  networking.networkmanager.enable = true;

  hardware.firmware = with pkgs; [
    broadcom-bt-firmware
    broadcom_sta
  ];

  boot.kernelModules = [ "wl" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

  ############################################
  # Bluetooth
  ############################################
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  ############################################
  # Audio — Intel HDA
  ############################################
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # Power Management (laptop tuned)
  ############################################
  services.upower.enable = true;

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      PCIE_ASPM_ON_BAT = "powersave";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
    };
  };

  ############################################
  # Boot performance
  ############################################
  boot.initrd.systemd.enable = true;

  boot.kernelParams = [
    "quiet"
    "splash"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "udev.log_level=3"
  ];

  ############################################
  # Graphics (Intel HD 3000)
  ############################################
  services.xserver.videoDrivers = [ "intel" ];

  environment.variables = {
    LIBGL_ALWAYS_SOFTWARE = "0";
  };

  ############################################
  # Laptop quirks
  ############################################
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
  };
}
