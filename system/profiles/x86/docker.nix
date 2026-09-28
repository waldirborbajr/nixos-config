# system/profiles/x86/docker.nix
#
# Docker Engine — sem toggle: se o host importa este arquivo, fica
# ligado (import = enable). Independente de podman.nix / kubernetes.nix.
{pkgs, ...}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # socket-activated: só sobe quando algo toca o socket
  };

  users.users.borba.extraGroups = ["docker"];

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
