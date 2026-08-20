# devshells/sqlite/flake.nix
{pkgs}: {
  # This makes it compatible with nix develop ./devshells/sqlite
  default = pkgs.mkShell {
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
