# system/profiles/x86/kubernetes.nix
#
# Ferramentas de Kubernetes local — import = enable. k9s sozinho NÃO
# sobe cluster nenhum (é só TUI pra um cluster que já existe); k3d cria
# um cluster k3s efêmero rodando como containers, então precisa de
# docker.nix OU podman.nix ativo no host.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    k3d
    kubectl
    k9s
  ];
}
