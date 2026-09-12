{
  description = "Application using uv2nix with SQLite and Helix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    pyproject-nix,
    uv2nix,
    pyproject-build-systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    forAllSystems = lib.genAttrs lib.systems.flakeExposed;

    hasUvLock = builtins.pathExists ./uv.lock;

    # Carrega o workspace apenas se uv.lock existir
    workspace =
      if hasUvLock
      then uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;}
      else null;

    # Define overlays apenas se workspace não for nulo
    overlay =
      if hasUvLock
      then
        workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        }
      else null;

    editableOverlay =
      if hasUvLock
      then
        workspace.mkEditablePyprojectOverlay {
          root = "$REPO_ROOT";
        }
      else null;

    # Conjunto de Python com overlays apenas se existir uv.lock
    pythonSets = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        python = pkgs.python3;
        base = pkgs.callPackage pyproject-nix.build.packages {inherit python;};
      in
        if hasUvLock
        then
          base.overrideScope (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.wheel
              overlay
            ]
          )
        else base # sem overlays, apenas o Python puro
    );

    name = ""; # Substitua pelo nome do seu projeto
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        pythonSet =
          if hasUvLock
          then (pythonSets.${system}.overrideScope editableOverlay)
          else pythonSets.${system}; # sem editable overlay

        # Cria virtualenv apenas se tiver uv.lock
        virtualenv =
          if hasUvLock
          then pythonSet.mkVirtualEnv "${name}-dev-env" workspace.deps.all
          else null;
      in {
        default = pkgs.mkShell {
          packages =
            [
              # Inclui virtualenv se existir, senão não inclui
              (
                if virtualenv != null
                then virtualenv
                else null
              )
              pkgs.uv
              pkgs.python3Packages.python-lsp-server
              pkgs.black
              pkgs.ruff
              pkgs.sqlite
              pkgs.sqlite-analyzer
              pkgs.helix
            ]
            ++ (
              if virtualenv == null
              then []
              else []
            )
            # remove null entries
            ; # filtramos os nulls

          env = {
            UV_NO_CACHE = "1";
            UV_NO_SYNC = "1";
            UV_PYTHON = pythonSet.python.interpreter;
            UV_PYTHON_DOWNLOADS = "never";
          };

          shellHook = ''
            unset PYTHONPATH
            export REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

            # Se não houver uv.lock, mostra instruções
            if [ ! -f uv.lock ]; then
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              echo "⚠️  uv.lock não encontrado!"
              echo "Execute os comandos abaixo para configurar o projeto:"
              echo ""
              echo "   uv init --app --name ${"name:-meu-projeto"} --packages"
              echo "   uv add <dependências>"
              echo "   uv lock"
              echo ""
              echo "Após isso, execute 'nix develop' novamente."
              echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            else
              # Se .venv existir, ativa (se não, apenas avisa)
              if [ -d .venv ]; then
                source .venv/bin/activate
                echo "✅ Virtualenv ativado (.venv)"
              else
                echo "ℹ️  Virtualenv não encontrado. Use 'uv sync' para criar."
              fi
            fi

            # Funções auxiliares SQLite (idênticas às dos outros ambientes)
            alias sqlite='sqlite3'
            alias sql='sqlite3'
            alias sqlq='sqlite3 -header -column'

            sqlquery() {
              if [ -z "$1" ] || [ -z "$2" ]; then
                echo "Uso: sqlquery <banco.db> <consulta SQL>"
                echo "Exemplo: sqlquery mydb.db \"SELECT * FROM users;\""
                return 1
              fi
              sqlite3 -header -column "$1" "$2"
            }

            sqli() {
              if [ -z "$1" ]; then
                echo "Uso: sqli <banco.db>"
                echo "Abre o shell interativo do SQLite com formatação melhorada"
                return 1
              fi
              sqlite3 -header -column "$1"
            }

            sqltables() {
              if [ -z "$1" ]; then
                echo "Uso: sqltables <banco.db>"
                return 1
              fi
              sqlite3 "$1" ".tables"
            }

            sqlschema() {
              if [ -z "$1" ]; then
                echo "Uso: sqlschema <banco.db> [tabela]"
                return 1
              fi
              if [ -z "$2" ]; then
                sqlite3 "$1" ".schema"
              else
                sqlite3 "$1" ".schema $2"
              fi
            }

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🐍 Ambiente Python (uv2nix)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 Python: $(python --version 2>/dev/null || echo 'não instalado')"
            echo "📦 UV:     $(uv --version)"
            echo "📦 SQLite: $(sqlite3 --version | head -1)"
            echo "📦 Helix:  $(hx --version 2>/dev/null | head -1 || echo 'instalado')"
            echo ""
            echo "🔧 Ferramentas disponíveis:"
            echo "   • uv (gerenciador de pacotes), python-lsp-server, black, ruff"
            echo "   • SQLite CLI (sqlite3) com funções auxiliares"
            echo "   • Helix (hx) – usa sua configuração ~/.config/helix"
            echo ""
            echo "🗄️  Funções auxiliares do SQLite:"
            echo "   • sqlquery <db> <query> - Executa uma consulta SELECT"
            echo "   • sqli <db> - Shell interativo do SQLite"
            echo "   • sqltables <db> - Lista todas as tabelas"
            echo "   • sqlschema <db> [tabela] - Mostra o esquema"
            echo "   • sql, sqlite - Atalhos para sqlite3"
            echo "   • sqlq - sqlite3 com cabeçalho e colunas"
            echo ""

            # Procura por arquivos de banco SQLite
            DB_FILES=$(find . -maxdepth 2 -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" 2>/dev/null | head -3)
            if [ -n "$DB_FILES" ]; then
              echo "🗄️  Bancos SQLite encontrados:"
              for db in $DB_FILES; do
                echo "   • $db ($(du -h "$db" | cut -f1))"
              done
              echo ""
            fi

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            if [ -f uv.lock ]; then
              echo "✨ Pronto! Use 'uv run <script>' ou 'uv shell' para ativar o virtualenv."
            else
              echo "⚠️  uv.lock ausente – execute 'uv lock' primeiro."
            fi
            echo "   SQLite: sqlquery mydb.db \"SELECT * FROM users;\""
            echo "   Helix:  hx ."
            echo ""
          '';
        };
      }
    );

    packages = forAllSystems (system: {
      default =
        if hasUvLock
        then pythonSets.${system}.mkVirtualEnv "${name}-env" workspace.deps.default
        else throw "uv.lock não encontrado. Execute 'uv lock' primeiro.";
    });
  };
}
