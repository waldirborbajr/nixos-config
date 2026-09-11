{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    python313

    # Resto do devshells/python que dá pra portar (o resto do flake ali é
    # uv2nix + workspace por-projeto, não faz sentido como módulo de sistema)
    uv
    python313Packages.python-lsp-server
    black
    ruff
    sqlite
    sqlite-analyzer
    helix
  ];
}
