# system/profiles/x86/podman.nix
#
# Podman rootless, sem daemon residente (fork-per-comando) — import =
# enable. Independente de docker.nix / kubernetes.nix.
{
  config,
  pkgs,
  ...
}: {
  virtualisation.podman = {
    enable = true;
    # O alias `docker` do podman colide com o binário do Docker Engine;
    # só liga quando docker.nix NÃO está ativo no host.
    dockerCompat = !config.virtualisation.docker.enable;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.oci-containers.backend = "podman";

  environment.systemPackages = with pkgs; [
    podman-compose
  ];

  # Weekly auto-update, opt-in por container via o label
  # `io.containers.autoupdate = "registry"`. `podman auto-update` compara
  # o digest local da tag fixada com o do registry e reinicia (com
  # rollback se o start/healthcheck falhar) só os que mudaram. NixOS não
  # tem uma option pra isso, então as units ficam declaradas aqui. Sem
  # efeito em hosts sem container nenhum com esse label.
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
