{ config, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./go.nix
    # ./postgres.nix
    ./python.nix
    ./rust.nix

    # Convertidos de devshells/ — comentados de propósito, descomente o que
    # for usar. Cada um só traz pacotes (ou serviço, no caso de maria/mongo)
    # pro sistema inteiro; nada disso é ativado por padrão.
    # ./arduino.nix
    # ./ferretdb.nix
    # ./latex.nix
    # ./lua.nix
    # ./mariadb.nix
    # ./mongodb.nix
     ./sqlite.nix
  ];
}
