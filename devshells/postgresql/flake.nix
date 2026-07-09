{
  description = "PostgreSQL development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        postgresShell = pkgs.mkShell {
          name = "postgresql-dev";

          buildInputs = with pkgs; [
            postgresql
            pgcli
          ];

          shellHook = ''
            export PGDATA="$HOME/.local/pgdata"
            export PATH="${pkgs.postgresql}/bin:$PATH"
            mkdir -p "$PGDATA"
            echo "🐘 PostgreSQL Development Environment"
            echo "psql: $(psql --version | head -n 1)"
            echo "pgcli: $(pgcli --version)"
          '';
        };
      in
      {
        devShells = {
          default = postgresShell;
          postgresql = postgresShell;
        };
      }
    );
}
