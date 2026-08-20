# devshells/default.nix
# Aggregates all development shells
{pkgs}: let
  # List of available devshells
  shells = [
    "go"
    "rust"
    "lua"
    "python"
    "arduino"
    "latex"
    "postgresql"
    "mariadb"
    "mongodb"
    "sqlite"
  ];
in
  pkgs.lib.genAttrs shells (
    name:
      import ./${name}/flake.nix {
        inherit pkgs;
      }
  )
