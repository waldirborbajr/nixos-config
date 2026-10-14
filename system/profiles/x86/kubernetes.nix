# system/profiles/x86/kubernetes.nix
#
# Ferramentas de Kubernetes local — toggle:
# development.containers.kubernetes.enable = true;
# k9s sozinho NÃO sobe cluster (é só TUI pra um cluster que já existe);
# k3d cria um cluster k3s efêmero rodando como containers, então precisa
# de docker OU podman ativo no mesmo host (assertion abaixo).
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.development.containers.kubernetes;
  runtimeOn =
    config.development.containers.docker.enable
    || config.development.containers.podman.enable;
in {
  options.development.containers.kubernetes.enable =
    lib.mkEnableOption "Kubernetes local (k3d, kubectl, k9s)";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = runtimeOn;
        message = "development.containers.kubernetes precisa de docker ou podman ligado no mesmo host (k3d roda o cluster em containers).";
      }
    ];

    environment.systemPackages = with pkgs; [
      k3d
      kubectl
      k9s
    ];
  };
}
