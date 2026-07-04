# hosts/dell/default.nix
{ lib, ... }:

{
  # Sobrescreve bootloader para BIOS legacy (Dell antigo)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";        # ← CONFIRME com `lsblk -f` no Dell
    # useOSProber = true;       # descomente se tiver Windows dual boot
  };

  # Keyboard (Mac layout)
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # Opcional: otimizações de performance para HDD (se for o caso)
  fileSystems."/" = {
    options = [ "noatime" "nodiratime" "commit=60" ];
  };
}
