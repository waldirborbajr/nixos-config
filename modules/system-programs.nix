{ pkgs, ... }:

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
      # OVMF images are now available by default in recent NixOS/Nixpkgs,
      # no need for ovmf.enable anymore
    };
  };

  ############################################
  # Docker (priority)
  ############################################
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  ############################################
  # Podman (rootless / docker-compatible)
  ############################################
  # Podman is commented out because Docker is currently enabled.
  # Podman with dockerCompat cannot coexist with Docker enabled.
  #
  # To switch to Podman in the future:
  # 1. Disable Docker: virtualisation.docker.enable = false;
  # 2. Uncomment the following Podman block
  #
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };

  ############################################
  # Polkit (for virt-manager GUI authorization)
  ############################################
  security.polkit.enable = true;
}
