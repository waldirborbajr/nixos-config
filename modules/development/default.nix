{ config, pkgs, ... }:
{
  imports = [
    # Base compartilhada por todos os ambientes de desenvolvimento.
    ./base.nix

    # Linguagens.
    ./go.nix
    # ./python.nix
    ./rust.nix
    # ./lua.nix
    ./nix.nix

    # Toolchains/ambientes especializados.
    # ./arduino.nix
    # ./latex.nix

    # Bancos e ferramentas de banco.
    # ./postgres.nix
    # ./mariadb.nix
    # ./mongodb.nix
    # ./ferretdb.nix
    ./sqlite.nix
  ];
}
