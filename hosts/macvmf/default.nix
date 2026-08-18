# hosts/macvmf/default.nix
{pkgs, ...}: {
  imports = [../common/mac-vm-workstation.nix];

  # VMware Fusion (não UTM)
  virtualisation.vmware.guest.enable = true;
  environment.systemPackages = [pkgs.open-vm-tools];
}
