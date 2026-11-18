# hosts/macutm/configuration.nix
# aarch64-linux — VM UTM no MacBook M2.
# Não importa os módulos x86/docker, x86/podman, x86/kubernetes —
# esses módulos são x86 only e saíram do base.nix. Containers não
# estão disponíveis neste host.
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
