# hosts/macvmf/configuration.nix
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
