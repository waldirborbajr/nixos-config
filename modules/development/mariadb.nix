{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.development.languages.mariadb.enable {
    # Ferramentas MariaDB. O serviço fica desativado por padrão para não
    # transformar o módulo de desenvolvimento em um daemon de sistema.
    services.mysql = {
      enable = lib.mkDefault false;
      package = pkgs.mariadb;
      ensureDatabases = ["dev"];
      ensureUsers = [
        {
          name = "root";
          ensurePermissions = {
            "*.*" = "ALL PRIVILEGES";
          };
        }
      ];
      settings = {
        mysqld = {
          skip-networking = false;
          bind-address = "127.0.0.1";
          port = 3306;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      mariadb
      mycli
    ];
  };
}
