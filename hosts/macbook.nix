{ ... }:

{
  imports = [
    ##########################################
    # Hardware
    ##########################################

    ../modules/hardware/macbook.nix
    ../modules/performance/macbook.nix

../hardware-configuration-macbook.nix

  ];
}
