# hosts/m2utm/default.nix
{ lib, ... }:

{
  # Bootloader - EFI (correto para VM no UTM)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Keyboard - US/Mac (para Mac M2 + UTM)
  console.keyMap = "us";

  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # Otimizações leves para VM
  boot.kernelParams = [ "mitigations=off" ]; # melhora performance em VMs

  # Opcional: melhor suporte a QEMU/UTM
  services.qemuGuest.enable = true;
}
