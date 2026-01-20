{ pkgs, ... }:

{
  ############################################
  # Core system services (NOT user packages)
  ############################################

  ############################################
  # DConf (GNOME / desktop settings backend)
  ############################################
  programs.dconf.enable = true;

  ############################################
  # Polkit (GUI authorization: virt-manager, NM)
  ############################################
  security.polkit.enable = true;

  ############################################
  # Virtualization (KVM / QEMU / Libvirt)
  ############################################
  virtualisation.libvirtd = {
    enable = true;

    allowedBridges = [
      "virbr0"
      "br0"
    ];

    qemu.swtpm.enable = true;
  };
}
