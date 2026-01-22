# profiles/dell.nix
# ---
{ config, pkgs, lib, ... }:

{
  ############################################
  # Host identity
  ############################################
  networking.hostName = "dell-nixos";

  ############################################
  # Bootloader (Legacy BIOS)
  ############################################
  boot.loader.grub = {
    enable = true;
    devices = [ "/dev/sda" ];
  };

  ############################################
  # Alterações para i3 no Dell
  ############################################
  
  # Desabilitar GNOME no Dell
  services.xserver.desktopManager.gnome.enable = false;

  # Habilitar i3 no Dell
  services.xserver.windowManager.i3.enable = true;

  # Configuração do teclado
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # Habilitar o X server
  services.xserver.enable = true;

  ############################################
  # Instalar i3 somente no Dell
  ############################################
  environment.systemPackages = with pkgs; lib.optionals (config.networking.hostName == "dell-nixos") [
    i3
  ];
}
