{
  description = "Go development environment with Helix editor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # Go version - using 1.25 which is stable and available
        goVersion = pkgs.go_1_25;

        # Common build inputs shared between shells
        commonBuildInputs = with pkgs; [
          # Core Go tools
          goVersion
          gopls # Language server
          delve # Debugger
          gotools # Various Go tools (goimports, etc.)
          gofumpt # Formatting tool
          golangci-lint # Linter
          golangci-lint-langserver # LSP wrapper

          # Build tools
          go-task # Task runner (like make)
          air # Hot reload for development
          watchexec # Watch and rebuild
          goreleaser # Release automation

          # Additional useful tools
          gomodifytags # Modify struct tags
          impl # Generate method stubs
          gotests # Generate tests

          # SQLite
          sqlite # Provides sqlite3 CLI
          sqlite-analyzer # Database analysis tool

          # Development utilities
          git
          gnumake
          jq
          ripgrep
          fd
          tree

          # Debugging
          gdb

          # Build essentials
          pkg-config
          openssl
          zlib

          # Helix editor
          helix # Will use your ~/.config/helix config
        ];

        # Function to create a Go development shell
        mkGoShell = {
          name ? "default",
          extraBuildInputs ? [],
          extraShellHook ? "",
        }:
          pkgs.mkShell {
            name = "go-dev-${name}";

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

            buildInputs = commonBuildInputs ++ extraBuildInputs;

            # Environment variables
            GO111MODULE = "on";
            GOPROXY = "https://proxy.golang.org,direct";
            GOSUMDB = "sum.golang.org";
            CGO_ENABLED = "1";
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";

            shellHook = ''
              # Set GOPATH to an absolute path using $HOME
              export GOPATH="$HOME/go"
              export GOBIN="$GOPATH/bin"
              export PATH="$GOBIN:${goVersion}/bin:$PATH"

              # Colorful prompt
              export PS1="(go-${name}) $PS1"

              # Ensure Go directories exist
              mkdir -p "$GOPATH" "$GOBIN" "$GOPATH/pkg" "$GOPATH/src"

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
              echo "🐹 Go Development Environment (${name})"
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "📦 Toolchain: $(go version)"
              echo "📦 GOROOT:     $(go env GOROOT)"
              echo "📦 GOPATH:     $GOPATH"
              echo "📦 GOBIN:      $GOBIN"
              echo "📦 GO111MODULE: $GO111MODULE"
              echo "📦 GOPROXY:    $GOPROXY"
              echo "📦 SQLite:     $(sqlite3 --version | head -1)"
              echo "📦 Helix:      $(hx --version 2>/dev/null | head -1 || echo 'installed')"
              echo ""
              echo "🔧 Tools available:"
              echo "   • Go: gopls (LSP), delve (debugger), gofumpt (formatter)"
              echo "   • Lint: golangci-lint with LSP wrapper"
              echo "   • Build: go-task (task runner), air (hot reload)"
              echo "   • Watch: watchexec (watch + rebuild)"
              echo "   • Go utils: gomodifytags, impl, gotests"
              echo "   • Release: goreleaser"
              echo "   • Dev: ripgrep, fd, tree, jq"
              echo "   • Editor: Helix (hx) – uses your ~/.config/helix"
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
              if [ -f go.mod ]; then
                PROJECT_NAME=$(grep '^module' go.mod | cut -d' ' -f2)
                GO_VERSION=$(grep '^go ' go.mod | cut -d' ' -f2)
                echo "📁 Project: $PROJECT_NAME (Go $GO_VERSION)"

                # Check if there's a Makefile or Taskfile
                if [ -f Makefile ]; then
                  echo "📋 Makefile detected - use 'make' for common tasks"
                fi
                if [ -f Taskfile.yml ] || [ -f Taskfile.yaml ]; then
                  echo "📋 Taskfile detected - use 'task' for common tasks"
                fi
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

              # Show installed Go tools version
              if command -v gopls &> /dev/null; then
                echo "📦 gopls:      $(gopls version 2>/dev/null | head -1 || echo 'installed')"
              fi
              if command -v golangci-lint &> /dev/null; then
                echo "📦 golangci-lint: $(golangci-lint version 2>/dev/null | head -1 || echo 'installed')"
              fi
              echo ""

              # Run custom shell hook
              ${extraShellHook}

              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "✨ Ready to code! Run 'go build' or 'go run .'"
              echo "   SQLite: sqlquery mydb.db \"SELECT * FROM users;\""
              echo "   Helix:  hx ."
              echo ""
            '';
          };
      in {
        devShells = {
          default = mkGoShell {
            name = "default";
          };

          go = mkGoShell {
            name = "default";
          };

          dev = mkGoShell {
            name = "dev";
            extraBuildInputs = with pkgs; [
              strace
              ltrace
              graphviz
              go-tools
            ];
            extraShellHook = ''
              echo "🔬 Debugging tools available:"
              echo "   • strace, ltrace"
              echo "   • graphviz (for profiling visualization)"
              echo ""
            '';
          };

          minimal = pkgs.mkShell {
            name = "go-dev-minimal";
            buildInputs = with pkgs; [
              goVersion
              git
              openssl
              zlib
              sqlite
              helix
            ];
            shellHook = ''
              export GOPATH="$HOME/go"
              export GOBIN="$GOPATH/bin"
              export PATH="$GOBIN:${goVersion}/bin:$PATH"
              echo "🐹 Minimal Go Environment"
              echo "Go: $(go version)"
              echo "SQLite: $(sqlite3 --version | head -1)"
              echo "Helix: $(hx --version 2>/dev/null | head -1 || echo 'installed')"
              echo "GOPATH: $GOPATH"
            '';
          };

          test = mkGoShell {
            name = "test";
            extraBuildInputs = with pkgs; [
              gotestsum
              go-critic
              gocyclo
              gosec
            ];
            extraShellHook = ''
              echo "🧪 Testing tools available:"
              echo "   • gotestsum (better test output)"
              echo "   • go-critic (additional linting)"
              echo "   • gocyclo (complexity analysis)"
              echo "   • gosec (security checking)"
              echo ""
            '';
          };

          sqlite = mkGoShell {
            name = "sqlite";
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
          go-toolchain = goVersion;
          sqlite-tools = pkgs.buildEnv {
            name = "sqlite-tools";
            paths = with pkgs; [
              sqlite
              sqlite-analyzer
            ];
          };
          dev-tools = pkgs.buildEnv {
            name = "go-dev-tools";
            paths = commonBuildInputs;
          };
          go-lsp = pkgs.writeShellScriptBin "go-lsp" ''
            exec gopls "$@"
          '';
        };
      }
    );
}
