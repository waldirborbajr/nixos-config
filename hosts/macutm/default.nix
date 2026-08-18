{
  pkgs,
  lib,
  ...
}: {
  imports = [../common/mac-vm-workstation.nix];

  environment.systemPackages = [pkgs.spice-vdagent];

  # cursor / DRM em virtio às vezes quebra sem isso
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # último recurso se ainda falhar:
    WLR_RENDERER = "pixman";
  };
}
