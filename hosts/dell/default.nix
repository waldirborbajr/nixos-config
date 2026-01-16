{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "dell";

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = true;
  };

  ############################################
  # Keyboard (Dell = PT-BR)
  ############################################
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  console.keyMap = "br-abnt2";
}

