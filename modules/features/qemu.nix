# modules/features/qemu.nix
{ lib, pkgs, qemuEnabled ? false, ... }:

{
  virtualisation.libvirtd.enable = lib.mkDefault false;

  config = lib.mkIf qemuEnabled {
    virtualisation.libvirtd.enable = true;

    # opcional: só instala pacotes quando QEMU=1 (bom pro Dell)
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      qemu
      spice
      spice-gtk
      spice-protocol
      virtio-win
    ];

    security.polkit.enable = true;
  };
}
