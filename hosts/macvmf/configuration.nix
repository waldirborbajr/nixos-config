# hosts/macvmf/configuration.nix
{
  pkgs,
  common,
  hostname,
  ...
}: {
  imports = [../../modules/mac_vm.nix];

  # ==================== HOME MANAGER (este host) ====================
  home-manager.users.${common.username} = import ../../home/${hostname}.nix;

  # VMware Fusion (não UTM)
  virtualisation.vmware.guest.enable = true;
  environment.systemPackages = [pkgs.open-vm-tools];
}
# ==================== PAINEL DE FEATURES ====================
// (import ../../features.nix).macvmf
