{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    flake-utils,
    fenix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        fenixPkgs = fenix.packages.${system};

        # Toolchain definitions
        stableToolchain = fenixPkgs.stable.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rustfmt"
          "rust-analyzer"
          "rust-src"
        ];

        nightlyToolchain = fenixPkgs.latest.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rustfmt"
          "rust-analyzer"
          "rust-src"
        ];

        # Common build inputs shared between shells
        commonBuildInputs = with pkgs; [
          # Rust tools
          cargo-edit
          cargo-watch
          cargo-make
          cargo-nextest
          bacon

          # Build essentials
          clang
          llvmPackages.bintools
          mold
          sccache
          pkg-config

          # System libraries
          openssl
          zlib

          # Development utilities
          git
          gnumake
          jq
          ripgrep
          fd
          tree

          # Debugging
          gdb
          lldb

          # Additional useful tools
          cargo-tarpaulin # Code coverage
          cargo-audit # Security auditing
          cargo-outdated # Dependency updates

          # SQLite
          sqlite # Provides sqlite3 CLI
          sqlite-analyzer # Database analysis tool

          # Helix editor
          helix # Will use your ~/.config/helix config
        ];

        # Function to create a Rust development shell
        mkRustShell = {
          name,
          toolchain,
          extraBuildInputs ? [],
          extraShellHook ? "",
        }:
          pkgs.mkShell {
            name = "rust-dev-${name}";

            # Keep important environment variables
            keep = [
              "PATH"
              "HOME"
              "USER"
              "TERM"
              "TERM_PROGRAM"
              "TERM_PROGRAM_VERSION"
              "SHELL"
              "DISPLAY"
              "XDG_*"
            ];

            nativeBuildInputs = with pkgs; [
              pkg-config
            ];

            buildInputs =
              [
                toolchain
              ]
              ++ commonBuildInputs ++ extraBuildInputs;

            # Environment variables
            RUST_SRC_PATH = "${toolchain}/lib/rustlib/src/rust/library";
            LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
            RUSTFLAGS = "-C link-arg=-fuse-ld=mold -C target-cpu=native";
            CARGO_BUILD_JOBS = "8"; # Adjust to your CPU cores or use "default"

            shellHook = ''
              # Colorful prompt
              export PS1="(rust-${name}) $PS1"

              # SQLite aliases
              alias sqlite='sqlite3'
              alias sql='sqlite3'
              alias sqlq='sqlite3 -header -column'

              # SQLite query function
              sqlquery() {
                if [ -z "$1" ] || [ -z "$2" ]; then
                  echo "Usage: sqlquery <database.db> <SQL query>"
                  echo "Example: sqlquery mydb.db \"SELECT * FROM users;\""
                  return 1
                fi
                sqlite3 -header -column "$1" "$2"
              }

              # SQLite interactive function
              sqli() {
                if [ -z "$1" ]; then
                  echo "Usage: sqli <database.db>"
                  echo "Opens interactive SQLite shell with enhanced formatting"
                  return 1
                fi
                sqlite3 -header -column "$1"
              }

              # Helper to list tables
              sqltables() {
                if [ -z "$1" ]; then
                  echo "Usage: sqltables <database.db>"
                  return 1
                fi
                sqlite3 "$1" ".tables"
              }

              # Helper to get schema
              sqlschema() {
                if [ -z "$1" ]; then
                  echo "Usage: sqlschema <database.db> [table_name]"
                  return 1
                fi
                if [ -z "$2" ]; then
                  sqlite3 "$1" ".schema"
                else
                  sqlite3 "$1" ".schema $2"
                fi
              }

              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "🦀 Rust Development Environment (${name})"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "📦 Toolchain: $(rustc --version)"
              echo "📦 Cargo:     $(cargo --version)"
              echo "📦 SQLite:    $(sqlite3 --version | head -1)"
              echo "📦 Helix:     $(hx --version 2>/dev/null | head -1 || echo 'installed')"
              echo ""
              echo "🔧 Tools available:"
              echo "   • cargo-edit, cargo-watch, cargo-make, cargo-nextest"
              echo "   • clippy, rustfmt, rust-analyzer"
              echo "   • bacon (watch + continuous check)"
              echo "   • mold (linker) + sccache (compile cache) active"
              echo "   • cargo-tarpaulin (coverage), cargo-audit (security)"
              echo "   • cargo-outdated (dependency updates)"
              echo "   • Helix (hx) – uses your ~/.config/helix"
              echo ""
              echo "🗄️  SQLite tools:"
              echo "   • sqlite3 - SQLite CLI"
              echo "   • sqlite-analyzer - Database analysis"
              echo ""
              echo "💡 SQLite helper functions:"
              echo "   • sqlquery <db> <query> - Run a SELECT query"
              echo "   • sqli <db> - Interactive SQLite shell"
              echo "   • sqltables <db> - List all tables"
              echo "   • sqlschema <db> [table] - Show schema"
              echo "   • sql, sqlite - Aliases for sqlite3"
              echo "   • sqlq - SQLite with header and column formatting"
              echo ""

              # Check for project
              if [ -f Cargo.toml ]; then
                PROJECT_NAME=$(grep '^name' Cargo.toml | head -1 | cut -d'"' -f2)
                PROJECT_VERSION=$(grep '^version' Cargo.toml | head -1 | tr -d ' ' | cut -d'"' -f2)
                echo "📁 Project: $PROJECT_NAME v$PROJECT_VERSION"

                # Count dependencies
                DEP_COUNT=$(grep -c '^[a-zA-Z]' Cargo.toml 2>/dev/null || echo "0")
                echo "📚 Dependencies: $DEP_COUNT"
                echo ""
              fi

              # Check for SQLite database files
              DB_FILES=$(find . -maxdepth 2 -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | head -3)
              if [ -n "$DB_FILES" ]; then
                echo "🗄️  Found SQLite databases:"
                for db in $DB_FILES; do
                  echo "   • $db ($(du -h "$db" | cut -f1))"
                done
                echo ""
              fi

              # Load .env file if exists
              if [ -f .env ]; then
                echo "📄 Loading .env file..."
                set -a
                source .env
                set +a
                echo "✅ Environment variables loaded from .env"
                echo ""
              fi

              # Check for direnv
              if [ ! -f .envrc ] && [ -z "$IN_NIX_SHELL" ]; then
                echo "💡 Tip: Use direnv for automatic shell activation:"
                echo "   echo 'use flake' > .envrc && direnv allow"
                echo ""
              fi

              # Show sccache stats
              if command -v sccache &> /dev/null; then
                echo "💾 Sccache stats:"
                ${pkgs.sccache}/bin/sccache --show-stats 2>/dev/null || true
                echo ""
              fi

              # Run custom shell hook
              ${extraShellHook}

              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "✨ Ready to code! Run 'cargo build' to get started."
              echo "   SQLite: sqlquery mydb.db \"SELECT * FROM users;\""
              echo "   Helix:  hx ."
              echo ""
            '';
          };
      in {
        devShells = {
          # Default shell (stable)
          default = mkRustShell {
            name = "stable";
            toolchain = stableToolchain;
          };

          # Stable Rust shell (alias for default)
          rust = mkRustShell {
            name = "stable";
            toolchain = stableToolchain;
          };

          # Nightly Rust shell
          rust-nightly = mkRustShell {
            name = "nightly";
            toolchain = nightlyToolchain;
            extraBuildInputs = [
              # Additional nightly-only tools
            ];
            extraShellHook = ''
              echo "⚠️  Using nightly Rust - features may be unstable"
              echo ""
            '';
          };

          # Development shell with additional debugging tools
          dev = mkRustShell {
            name = "dev";
            toolchain = stableToolchain;
            extraBuildInputs = with pkgs; [
              valgrind
              strace
              ltrace
            ];
            extraShellHook = ''
              echo "🔬 Debugging tools available:"
              echo "   • valgrind, strace, ltrace"
              echo ""
            '';
          };

          # Minimal shell (for CI or resource-constrained environments)
          minimal = pkgs.mkShell {
            name = "rust-dev-minimal";
            buildInputs = with pkgs; [
              stableToolchain
              pkg-config
              openssl
              zlib
              sqlite
              helix
            ];
            RUST_SRC_PATH = "${stableToolchain}/lib/rustlib/src/rust/library";
            shellHook = ''
              echo "🦀 Minimal Rust Environment"
              echo "Rust: $(rustc --version)"
              echo "Cargo: $(cargo --version)"
              echo "SQLite: $(sqlite3 --version | head -1)"
              echo "Helix: $(hx --version 2>/dev/null | head -1 || echo 'installed')"
            '';
          };

          # SQLite-focused shell
          sqlite = mkRustShell {
            name = "sqlite";
            toolchain = stableToolchain;
            extraShellHook = ''
              echo "🗄️  SQLite Development Environment"
              echo "SQLite version: $(sqlite3 --version | head -1)"
              echo ""
              echo "💡 Examples:"
              echo "   sqlquery test.db \"SELECT * FROM sqlite_master;\""
              echo "   sqli test.db"
              echo "   sqlschema test.db"
              echo ""
            '';
          };
        };

        packages = {
          rust-stable = stableToolchain;
          rust-nightly = nightlyToolchain;
          dev-tools = pkgs.buildEnv {
            name = "rust-dev-tools";
            paths = commonBuildInputs ++ [stableToolchain];
          };
          sqlite-tools = pkgs.buildEnv {
            name = "sqlite-tools";
            paths = with pkgs; [
              sqlite
              sqlite-analyzer
            ];
          };
        };
      }
    );
}
