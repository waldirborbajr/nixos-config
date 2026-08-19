# hosts/m2utm/hardware-configuration.nix
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "usbhid" "usb_storage" "sr_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a90795c7-0664-4635-9219-40afa6f1f741";
    fsType = "ext4";
    options = ["noatime" "nodiratime"]; # boa prática em VMs
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/FBB9-A619";
    fsType = "vfat";
    options = ["fmask=0077" "dmask=0077"];
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # Microcode não se aplica em VM Apple Silicon
  hardware.cpu.intel.updateMicrocode = lib.mkDefault false;
}
