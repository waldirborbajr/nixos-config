{
  description = "MariaDB development environment";

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
        mariadbShell = pkgs.mkShell {
          name = "mariadb-dev";

          buildInputs = with pkgs; [
            mariadb
            mycli
          ];

          shellHook = ''
            export MYSQL_UNIX_PORT="$HOME/.local/mariadb/mysql.sock"
            mkdir -p "$(dirname "$MYSQL_UNIX_PORT")"
            echo "🗄️ MariaDB Development Environment"
            echo "mariadb: $(mariadb --version | head -n 1)"
            echo "mycli: $(mycli --version)"
          '';
        };
      in
      {
        devShells = {
          default = mariadbShell;
          mariadb = mariadbShell;
        };
      }
    );
}
