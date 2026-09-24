# system/profiles/x86/containers.nix
#
# Docker / Podman / Kubernetes local — opt-in, ligado individualmente
# via containerTools.*.enable direto no configuration.nix do host que
# importar este arquivo. Junta o que antes eram 4 arquivos separados
# (modules/containers.nix + containers_docker.nix + containers_podman.nix
# + containers_kubernetes.nix); os 3 `config = lib.mkIf ...` viram um só
# `lib.mkMerge` (duas atribuições de `config` no mesmo arquivo não
# compilam).
#
# Namespace containerTools (não "containers") porque o NixOS já usa
# `containers.*` pra nixos-containers/systemd-nspawn — reaproveitar esse
# nome quebra o merge de opções.
{
  pkgs,
  common,
  config,
  lib,
  ...
}: let
  inherit (common) username;
in {
  options.containerTools = {
    docker.enable = lib.mkEnableOption "Docker Engine (dockerd, socket-activated)";
    podman.enable = lib.mkEnableOption "Podman rootless (dockerCompat + rede default)";
    kubernetes.enable = lib.mkEnableOption "Kubernetes local (k3d + kubectl + k9s)";
  };

  config = lib.mkMerge [
    (lib.mkIf config.containerTools.docker.enable {
      # enableOnBoot = false: dockerd fica parado até você realmente tocar
      # o socket (ex: `docker ps`) — socket-activated, não sobe sozinho no
      # boot. Depois de subir uma vez, fica rodando até `systemctl stop
      # docker` ou reboot — trade-off de usar o Docker "de verdade" em vez
      # do Podman.
      virtualisation.docker = {
        enable = true;
        enableOnBoot = false;
      };

      users.users.${username}.extraGroups = ["docker"];

      environment.systemPackages = with pkgs; [
        docker-compose
      ];
    })

    (lib.mkIf config.containerTools.podman.enable {
      # Rootless, sem daemon residente: fork-per-comando, só existe
      # enquanto o comando roda. dockerCompat = true dá o alias `docker`
      # pra Dockerfiles/scripts que esperam esse nome.
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      environment.systemPackages = with pkgs; [
        podman-compose
        lazydocker
      ];
    })

    (lib.mkIf config.containerTools.kubernetes.enable {
      # k9s sozinho NÃO sobe cluster nenhum — é só dashboard/TUI pra um
      # cluster que já existe. k3d cria um cluster k3s efêmero rodando
      # como containers, em cima do runtime que já estiver ligado.
      # Nenhum dos três é serviço systemd — só binários; o cluster só
      # existe entre um `k3d cluster create` e um `k3d cluster delete`.
      environment.systemPackages = with pkgs; [
        k3d
        kubectl
        k9s
      ];

      assertions = [
        {
          assertion = config.containerTools.docker.enable || config.containerTools.podman.enable;
          message = "containerTools.kubernetes.enable precisa de containerTools.docker.enable ou containerTools.podman.enable (k3d cria os nodes do cluster como containers).";
        }
      ];
    })
  ];
}
