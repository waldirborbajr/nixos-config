{ ... }:

{
  ############################################
  # MacBook Pro 13" 2011 (EFI)
  ############################################

  imports = [
    ../../modules/hardware-macbook.nix
    ../hardware-macbook.nix
  ];

  # GRUB should NOT be used on MacBook
  boot.loader.grub.enable = false;
}
