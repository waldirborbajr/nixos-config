# system/profiles/x86/containers.nix
#
# Docker + Podman + Kubernetes local — sem sistema de toggle: se o host
# importa este arquivo, tudo aqui fica ligado (igual ao padrão do
# ulyssecrn — import = enable, sem options.*.enable no meio do caminho).
{
  config,
  pkgs,
  ...
}: {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # socket-activated: só sobe quando algo toca o socket
  };

  # Rootless, sem daemon residente: fork-per-comando, só existe enquanto
  # o comando roda. dockerCompat = true dá o alias `docker` pra
  # Dockerfiles/scripts que esperam esse nome (convive com o Docker Engine
  # acima; use um ou outro por projeto).
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  users.users.borba.extraGroups = ["docker"];

  environment.systemPackages = with pkgs; [
    docker-compose
    podman-compose
    lazydocker

    # k9s sozinho NÃO sobe cluster nenhum — é só dashboard/TUI pra um
    # cluster que já existe. k3d cria um cluster k3s efêmero rodando
    # como containers, em cima do Docker/Podman acima.
    k3d
    kubectl
    k9s
  ];

  # Weekly auto-update, opt-in por container via o label
  # `io.containers.autoupdate = "registry"`. `podman auto-update` compara
  # o digest local da tag fixada com o do registry e reinicia (com
  # rollback se o start/healthcheck falhar) só os que mudaram. NixOS não
  # tem uma option pra isso, então as units ficam declaradas aqui. Sem
  # efeito em hosts sem container nenhum com esse label — mesmo padrão
  # do ulyssecrn.
  systemd.services.podman-auto-update = {
    description = "Auto-update opted-in podman containers";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.virtualisation.podman.package}/bin/podman auto-update";
      ExecStartPost = "${config.virtualisation.podman.package}/bin/podman image prune -f";
    };
  };
  systemd.timers.podman-auto-update = {
    description = "Weekly podman auto-update";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "Sun *-*-* 04:00:00";
      Persistent = true;
      RandomizedDelaySec = "45m";
    };
  };
}
