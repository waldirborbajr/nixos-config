_: let
  common = import ./global_constants.nix;
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix

    ./modules/base_system.nix
    ./modules/fonts.nix
    ./modules/user_borba.nix
    ./modules/desktop_niri.nix
    ./modules/audio.nix
    ./modules/hardware_quirks.nix
    ./modules/root_pkgs.nix
    ./modules/ssh.nix
    ./modules/sops.nix

    # ==================== CONTAINERS / K8S (sob demanda) ====================
    # Sempre importado; Docker, Podman e Kubernetes local são ligados
    # individualmente via containerTools.*.enable — ver features.nix,
    # que é o painel único onde cada host liga/desliga isso.
    ./modules/containers.nix

    # ==================== DEVELOPMENT ====================
    # Base comum + linguagens explicitamente habilitadas — ver
    # features.nix (o painel) para o que cada host liga.
    ./modules/dev/default.nix
  ];

  # NOTA: os valores de containerTools.* e development.languages.* NÃO
  # ficam mais fixos aqui (eram idênticos pros 4 hosts). Cada
  # hosts/<host>/configuration.nix agora aplica o bloco correspondente
  # de features.nix — esse é o "lugar único pra ligar/desligar" que
  # antes não existia por host.

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
