{ config, pkgs, lib, ... }:

{
  ############################################
  # Bridge networking for libvirt
  ############################################

  networking.networkmanager.enable = true;

  networking.bridges.br0.interfaces = [ ];

  networking.interfaces.br0.useDHCP = true;

  ############################################
  # NetworkManager bridge support
  ############################################
  networking.networkmanager.unmanaged = [ "interface-name:virbr*" ];

  ############################################
  # Libvirt bridge permission
  ############################################
  virtualisation.libvirtd.allowedBridges = [ "br0" ];
}
