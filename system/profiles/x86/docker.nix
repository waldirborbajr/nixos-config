# system/profiles/x86/docker.nix
#
# Docker Engine — toggle: development.containers.docker.enable = true;
# (sem import comentado). socket-activated (enableOnBoot = false).
# Independente de podman.nix / kubernetes.nix.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.containers.docker;
in {
  options.development.containers.docker.enable =
    lib.mkEnableOption "Docker Engine (socket-activated, grupo docker)";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false; # só sobe quando algo toca o socket
    };

    users.users.borba.extraGroups = ["docker"];

    environment.systemPackages = with pkgs; [
      docker-compose
      lazydocker
    ];
  };
}
