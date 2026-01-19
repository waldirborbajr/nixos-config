{ config, pkgs, ... }:

{
  ############################################
  # Core Programs
  ############################################
  programs = {
    zsh.enable = true;

    firefox = {
      enable = true;
      package = pkgs.firefox;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    dconf.enable = true;
  };

  ############################################
  # Virtualization (KVM / QEMU / Libvirt)
  ############################################
  virtualisation.libvirtd = {
    enable = true;

    allowedBridges = [
      "virbr0"
      "br0"
    ];

    qemu = {
      swtpm.enable = true;
      ovmf.enable = true;
    };
  };

  ############################################
  # Docker (opcional)
  ############################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  ############################################
  # Podman (rootless / docker-compatible)
  ############################################
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  ############################################
  # Polkit (virt-manager, GUI auth)
  ############################################
  security.polkit.enable = true;
}
