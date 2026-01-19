{ config, pkgs, lib, ... }:

{
  ############################################
  # EFI / Boot tuning — MacBook Pro 2011
  ############################################

  ############################################
  # EFI bootloader
  ############################################
  boot.loader = {
    systemd-boot.enable = true;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };

  ############################################
  # systemd-boot tuning
  ############################################
  boot.loader.systemd-boot = {
    editor = false;
    configurationLimit = 8;
  };

  ############################################
  # Fast boot (EFI friendly)
  ############################################
  boot.initrd.systemd.enable = true;

  ############################################
  # Kernel params — silent & fast
  ############################################
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "udev.log_level=3"
    "vt.global_cursor_default=0"
    "fbcon=nodefer"
  ];

  ############################################
  # Reduce EFI boot delay
  ############################################
  boot.kernel.sysctl = {
    "kernel.printk" = "3 3 3 3";
  };

  ############################################
  # Disable Plymouth (old GPU friendly)
  ############################################
  boot.plymouth.enable = false;

  ############################################
  # Filesystem check optimization
  ############################################
  boot.initrd.checkJournalingFS = false;

  ############################################
  # Emergency shell (avoid slow fallback)
  ############################################
  boot.initrd.emergencyAccess = false;
}
