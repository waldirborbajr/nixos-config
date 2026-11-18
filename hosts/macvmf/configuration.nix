# hosts/macvmf/configuration.nix
# aarch64-linux — VM VMware Fusion no MacBook M2.
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

  # VMware Fusion (não UTM)
  virtualisation.vmware.guest.enable = true;
  environment.systemPackages = [pkgs.open-vm-tools];

  system.stateVersion = "26.05";
}
