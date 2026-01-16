# Seu home.nix
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    docker
    docker-compose
    # lazydocker    # opcional, interface tui bem útil
  ];

  # Opcional: tenta habilitar socket rootless (funciona só se o sistema já tiver
  # rootless docker habilitado ou se você usar podman rootless)
  # systemd.user.services.docker = {
  #   ...
  # };

  # Alternativa muito mais comum hoje em dia: usar podman rootless (mais fácil)
  # programs.podman.enable = true;   ← existe no home-manager em versões recentes!
}
