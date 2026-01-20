{ config, pkgs, lib, ... }:

{
  ############################################
  # Docker (system service)
  ############################################
  virtualisation.docker = {
    enable = true;

    # Força Docker para iniciar no boot, sobrescrevendo qualquer outro valor
    enableOnBoot = lib.mkForce true;
  };

  ############################################
  # User access
  ############################################
  users.users.borba.extraGroups = lib.mkForce (users.users.borba.extraGroups ++ [ "docker" ]);

  ############################################
  # Podman (rootless / docker-compatible)
  ############################################
  # Para usar Podman no futuro (desative Docker primeiro)
  # virtualisation.podman = {
  #   enable = true;
  #   dockerCompat = true;
  #   defaultNetwork.settings.dns_enabled = true;
  # };
}
