# hosts/macutm/configuration.nix
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/profiles/base.nix
    ../../system/profiles/desktop.nix
    ../../system/profiles/x86/desktop.nix
    ../../system/modules/mac-family.nix
    ../../system/modules/mac-vm.nix
  ];

  environment.systemPackages = [pkgs.spice-vdagent];

  # cursor / DRM em virtio às vezes quebra sem isso
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    # último recurso se ainda falhar:
    WLR_RENDERER = "pixman";
  };

  system.stateVersion = "26.05";
}
