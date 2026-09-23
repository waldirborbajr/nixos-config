{
  pkgs,
  common,
  hostname,
  ...
}:
{
  imports = [../../modules/mac_vm.nix];

  # ==================== HOME MANAGER (este host) ====================
  home-manager.users.${common.username} = import ../../home/${hostname}.nix;

  environment.systemPackages = [pkgs.spice-vdagent];

  # cursor / DRM em virtio às vezes quebra sem isso
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # último recurso se ainda falhar:
    WLR_RENDERER = "pixman";
  };
}
# ==================== PAINEL DE FEATURES ====================
// (import ../../features.nix).macutm
