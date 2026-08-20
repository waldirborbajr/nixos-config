# devshells/sqlite/flake.nix
# SQLite development environment
{
  description = "SQLite development shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            sqlite
            sqlite-interactive
            sqlite-analyzer
            sqlite-docs
          ];

          shellHook = ''
            echo "🔷 SQLite Development Environment"
            echo "SQLite version: $(sqlite3 --version)"
            echo ""
            echo "Available tools:"
            echo "  - sqlite3: Interactive SQLite client"
            echo "  - sqlite3_analyzer: Analyze SQLite databases"
            echo "  - sqlite3_docs: SQLite documentation"
            echo ""
            echo "Quick start:"
            echo "  sqlite3 test.db"
            echo "  .tables"
            echo "  .schema"
          '';
        };
      }
    );
}
