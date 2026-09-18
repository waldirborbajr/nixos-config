# modules/system/containers-docker.nix
#
# Docker Engine — desligado por padrão. Controlado por
# containers.docker.enable (ver modules/system/containers.nix e
# configuration.nix).
#
# enableOnBoot = false: dockerd fica parado até você realmente tocar o
# socket (ex: `docker ps`) — socket-activated, não sobe sozinho no boot.
# Depois de subir uma vez, fica rodando até `systemctl stop docker` ou
# reboot (não é fork-per-comando como o Podman) — é o trade-off de usar
# o Docker "de verdade" em vez de containers-podman.nix.
{
  pkgs,
  common,
  config,
  lib,
  ...
}: let
  inherit (common) username;
in {
  config = lib.mkIf config.containers.docker.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
    };

    users.users.${username}.extraGroups = ["docker"];

    environment.systemPackages = with pkgs; [
      docker-compose
    ];
  };
}
