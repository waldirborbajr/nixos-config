{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/mariadb (nix develop). O devshell original subia
# um mysqld_safe standalone em $HOME/.local/mariadb (start/stop manual via
# mariadb-start/mariadb-stop). Aqui usamos o módulo services.mysql do NixOS
# (mesma ideia do modules/development/postgres.nix) — o systemd cuida do
# start/stop, mas ainda assim é um serviço de sistema, então fica comentado
# no default.nix até você decidir ativar.
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    # Dev: sem senha, acesso local livre (não use isso em produção)
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
}
