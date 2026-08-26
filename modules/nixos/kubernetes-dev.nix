# modules/nixos/kubernetes-dev.nix
#
# Kubernetes local, pra quando precisar — desligado por padrão. Import
# comentado em configuration.nix; descomente, rode o rebuild, use;
# comente de novo e rebuild quando não precisar mais.
#
# Correção importante (pedido original citava só k9s): k9s sozinho NÃO
# sobe cluster nenhum — é só um dashboard/TUI pra um cluster que já
# existe (local ou remoto), via kubeconfig. Pra ter um cluster local de
# verdade, a opção mais leve é k3d (cria um cluster k3s efêmero rodando
# como containers, em cima do runtime que você já tiver ligado) +
# kubectl + k9s pro dashboard. Nenhum dos três é serviço systemd — são
# só binários; o cluster só existe entre um `k3d cluster create` e um
# `k3d cluster delete`.
#
# Precisa de containers-docker.nix OU containers-podman.nix habilitado
# junto — o k3d cria os "nodes" do cluster como containers.
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    k3d
    kubectl
    k9s
  ];
}
