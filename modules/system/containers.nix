# modules/system/containers.nix
#
# Ponto central das opções de containers/K8s local — mesmo padrão de
# modules/development/default.nix (options.development.languages.*).
# Os três módulos abaixo são sempre importados; o que liga ou desliga
# cada um é containers.<tool>.enable no configuration.nix (ou por host).
{
  config,
  lib,
  ...
}: {
  imports = [
    ./containers-docker.nix
    ./containers-podman.nix
    ./kubernetes-dev.nix
  ];

  options.containers = {
    docker.enable = lib.mkEnableOption "Docker Engine (dockerd, socket-activated)";
    podman.enable = lib.mkEnableOption "Podman rootless (dockerCompat + rede default)";
    kubernetes.enable = lib.mkEnableOption "Kubernetes local (k3d + kubectl + k9s)";
  };

  config = lib.mkIf config.containers.kubernetes.enable {
    assertions = [
      {
        assertion = config.containers.docker.enable || config.containers.podman.enable;
        message = "containers.kubernetes.enable precisa de containers.docker.enable ou containers.podman.enable (k3d cria os nodes do cluster como containers).";
      }
    ];
  };
}
