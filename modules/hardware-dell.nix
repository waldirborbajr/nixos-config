{ config, pkgs, ... }:

{
  ############################################
  # Wi-Fi e Bluetooth
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  ############################################
  # Audio (PipeWire)
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
  # Keyboard — Dell Inspiron (pt_BR)
  ############################################
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";

  ############################################
  # Bootloader (GRUB + desativa os-prober)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.extraEntries = '' '';

  ############################################
  # Kernel Modules
  ############################################
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "ums_realtek" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
}
