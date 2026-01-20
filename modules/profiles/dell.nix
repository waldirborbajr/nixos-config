{ ... }:

{
  ############################################
  # Dell Inspiron 1564 (Legacy BIOS)
  ############################################

  imports = [
    ../../hardware-configuration-dell.nix
    ../hardware-dell.nix
  ];

  boot.loader.grub.enable = true;
}
