_: let
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

    ./modules/system/system-base.nix
    ./modules/system/fonts.nix
    ./modules/system/users-and-home.nix
    ./modules/system/desktop-niri.nix
    ./modules/system/audio.nix
    ./modules/system/hardware-quirks.nix
    ./modules/system/packages.nix
    ./modules/system/ssh.nix
    ./modules/system/sops.nix

    # ==================== CONTAINERS / K8S (sob demanda) ====================
    # Sempre importado; Docker, Podman e Kubernetes local são ligados
    # individualmente via containerTools.*.enable abaixo (mesmo padrão de
    # development.languages). docker e podman são independentes (pode
    # ligar só um, ou os dois); kubernetes precisa de um dos dois ligado
    # junto, já que o k3d cria os nodes do cluster como containers.
    ./modules/system/containers.nix

    # ==================== DEVELOPMENT ====================
    # Base comum + linguagens explicitamente habilitadas abaixo.
    ./modules/development/default.nix
  ];

  # Containers / Kubernetes local — desligados por padrão.
  containerTools = {
    docker.enable = false;
    podman.enable = false;
    kubernetes.enable = false;
  };

  # Linguagens de desenvolvimento explicitamente habilitadas.
  development.languages = {
    nix.enable = true;
    go.enable = true;
    rust.enable = true;

    python.enable = false;
    lua.enable = false;
    arduino.enable = false;
    latex.enable = false;
    postgresql.enable = false;
    mariadb.enable = false;
    mongodb.enable = false;
    ferretdb.enable = false;
    sqlite.enable = false;
  };

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
