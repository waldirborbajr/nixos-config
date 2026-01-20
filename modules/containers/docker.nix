{ config, pkgs, lib, ... }:

{
  ############################################
  # Docker (system service)
  ############################################
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = lib.mkForce true;

  ############################################
  # Podman (comentado, use no futuro se desligar Docker)
  ############################################
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;
  # virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
}
