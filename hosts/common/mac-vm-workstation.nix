# hosts/common/mac-vm-workstation.nix
#
# Camada VM por cima de mac-workstation.nix.
# Usado por macutm e macvmf. Só o agente de guest (UTM vs Fusion) e o
# hardware-configuration.nix continuam específicos de cada host.
#
# Programas / browsers / teclado → hosts/common/mac-workstation.nix
{ lib, pkgs, pkgs-unstable, common, ... }:
let
  inherit (common) username;
  niriInput   = ../../home/configs/niri/config/input-mac.kdl;
  niriOutputs = ../../home/configs/niri/config/outputs-macvm.kdl;
in {
  imports = [ ./mac-workstation.nix ];

  # ==================== BOOT (extras de VM) ====================
  boot.kernelParams = [ "mitigations=off" ]; # ajuda em VMs

  # ==================== CONTAINERS ====================
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # ==================== GRAPHICS (VM / virtio-gpu) ====================
  # Required for niri (Wayland) under UTM / Fusion — avoids black screen after login.
  hardware.graphics.enable = true;
  boot.kernelModules = [ "virtio_gpu" "virtio_pci" ];

  # ==================== HOME MANAGER (niri/waybar das VMs) ====================
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = niriInput;
    xdg.configFile."niri/config/outputs.kdl".source = niriOutputs;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-macvm.jsonc;
  };
}
