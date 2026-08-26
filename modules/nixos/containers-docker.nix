# modules/nixos/containers-docker.nix
#
# Docker Engine — desligado por padrão. Import comentado em
# configuration.nix; descomente, rode o rebuild, use; comente de novo e
# rebuild quando não precisar mais.
#
# enableOnBoot = false: dockerd fica parado até você realmente tocar o
# socket (ex: `docker ps`) — socket-activated, não sobe sozinho no boot.
# Depois de subir uma vez, fica rodando até `systemctl stop docker` ou
# reboot (não é fork-per-comando como o Podman) — é o trade-off de usar
# o Docker "de verdade" em vez de containers-podman.nix.
{
  pkgs,
  common,
  ...
}: let
  inherit (common) username;
in {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };

  users.users.${username}.extraGroups = ["docker"];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
