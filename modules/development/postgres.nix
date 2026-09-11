{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Ferramentas PostgreSQL. O serviço permanece desativado por padrão:
  # o módulo pode ser habilitado explicitamente quando um host realmente
  # precisar do servidor.
  services.postgresql = {
    enable = lib.mkDefault false;
    package = pkgs.postgresql_16;
    ensureDatabases = [
      "dev"
      "borba"
    ];
    ensureUsers = [
      {
        name = "borba";
        ensureDBOwnership = true;
        ensureClauses.superuser = true;
      }
    ];
    authentication = ''
      local all all trust
      host all all 127.0.0.1/32 trust
    '';
    settings = {
      log_statement = "all";
      fsync = false;
      synchronous_commit = false;
    };
    extensions =
      ps: with ps; [
        pgvector
        pg_uuidv7
      ];
  };

  environment.systemPackages = with pkgs; [
    postgresql
    pgcli
  ];
}
