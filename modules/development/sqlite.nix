{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/sqlite (nix develop). As funções de shell
# (sql-create, sql-query, etc.) eram só wrappers finos em cima do sqlite3
# CLI — não fazem sentido fora do devshell, então ficaram de fora.
{
  environment.systemPackages = with pkgs; [
    sqlite # CLI + biblioteca
    sqlite-analyzer
  ];
}
