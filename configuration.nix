{...}: let
  username = "borba";

  # Shared values for host modules (username mainly).
  # Dotfile contents now live inside the flake under home/configs/ (fase 3).
  common = {
    inherit username;
  };
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix

    ./modules/nixos/system-base.nix
    ./modules/nixos/fonts.nix
    ./modules/nixos/users-and-home.nix
    ./modules/nixos/desktop-niri.nix
    ./modules/nixos/audio.nix
    ./modules/nixos/hardware-quirks.nix
    ./modules/nixos/packages.nix
    ./modules/nixos/ssh.nix
    ./modules/nixos/sops.nix

    # ==================== CONTAINERS / K8S (sob demanda) ====================
    # Docker, Podman e Kubernetes local são usados só em projetos
    # específicos, não no dia a dia — ficam desligados por padrão.
    # Descomente a linha relevante, rode o rebuild, use; comente de novo e
    # rebuild quando não precisar mais. containers-docker.nix e
    # containers-podman.nix são independentes (pode ligar só um, ou os
    # dois); kubernetes-dev.nix (k3d+kubectl+k9s) precisa de um dos dois
    # ligado junto, já que o k3d cria os nodes do cluster como containers.
    # ./modules/nixos/containers-docker.nix
    # ./modules/nixos/containers-podman.nix
    # ./modules/nixos/kubernetes-dev.nix
  ];

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
