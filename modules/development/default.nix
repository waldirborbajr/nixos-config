{lib, ...}:
{
  imports = [
    ./base.nix
    ./go.nix
    ./python.nix
    ./rust.nix
    ./lua.nix
    ./nix.nix
    ./arduino.nix
    ./latex.nix
    ./postgres.nix
    ./mariadb.nix
    ./mongodb.nix
    ./ferretdb.nix
    ./sqlite.nix
  ];

  options.development.languages = {
    nix.enable = lib.mkEnableOption "Nix development tooling";
    go.enable = lib.mkEnableOption "Go development tooling";
    python.enable = lib.mkEnableOption "Python development tooling";
    rust.enable = lib.mkEnableOption "Rust development tooling";
    lua.enable = lib.mkEnableOption "Lua development tooling";
    arduino.enable = lib.mkEnableOption "Arduino development tooling";
    latex.enable = lib.mkEnableOption "LaTeX/Typst development tooling";
    postgresql.enable = lib.mkEnableOption "PostgreSQL development tooling";
    mariadb.enable = lib.mkEnableOption "MariaDB development tooling";
    mongodb.enable = lib.mkEnableOption "MongoDB development tooling";
    ferretdb.enable = lib.mkEnableOption "FerretDB development tooling";
    sqlite.enable = lib.mkEnableOption "SQLite development tooling";
  };
}
