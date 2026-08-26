# modules/nixos/containers-podman.nix
#
# Podman — desligado por padrão. Import comentado em configuration.nix;
# descomente, rode o rebuild, use; comente de novo e rebuild quando não
# precisar mais.
#
# Rootless, sem daemon residente: ao contrário do Docker, não tem
# serviço pra ficar rodando à toa quando você não está usando — é
# fork-per-comando, só existe enquanto o comando roda. dockerCompat =
# true dá o alias `docker` (docker run/build/etc. viram podman por
# baixo), pra Dockerfiles/scripts que esperam esse nome funcionarem sem
# alteração.
#
# Nota: a família Mac (hosts/common/mac-workstation.nix) já tem um
# pacote `podman` cru (+ lazydocker) pra uso básico rootless. Este
# módulo é outra coisa — habilita o wiring de sistema de verdade
# (virtualisation.podman: dockerCompat, rede default) e serve pra
# qualquer host, não só a família Mac. Habilitar aqui num host Mac não
# quebra nada (Nix deduplica o pacote), só passa a ligar o compat/rede
# que o pacote cru sozinho não configura.
{pkgs, ...}: {
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    lazydocker
  ];
}
