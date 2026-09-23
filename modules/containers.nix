# modules/containers.nix
#
# Ponto central das opções de containers/K8s local — mesmo padrão de
# modules/dev/default.nix (options.development.languages.*).
# Namespace containerTools (não "containers") porque o próprio NixOS já
# usa `containers.*` para nixos-containers/systemd-nspawn — reaproveitar
# esse nome quebra o merge de opções.
{
  config,
  lib,
  ...
}: {
  imports = [
    ./containers_docker.nix
    ./containers_podman.nix
    ./containers_kubernetes.nix
  ];

  options.containerTools = {
    docker.enable = lib.mkEnableOption "Docker Engine (dockerd, socket-activated)";
    podman.enable = lib.mkEnableOption "Podman rootless (dockerCompat + rede default)";
    kubernetes.enable = lib.mkEnableOption "Kubernetes local (k3d + kubectl + k9s)";
  };

  config = lib.mkIf config.containerTools.kubernetes.enable {
    assertions = [
      {
        assertion = config.containerTools.docker.enable || config.containerTools.podman.enable;
        message = "containerTools.kubernetes.enable precisa de containerTools.docker.enable ou containerTools.podman.enable (k3d cria os nodes do cluster como containers).";
      }
    ];
  };
}
