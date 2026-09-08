{
  description = "PostgreSQL standalone development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        dataDir = "$HOME/.local/pgdata";
        socketDir = "$HOME/.local/postgres";
        port = 5432;
        user = "postgres";
        password = "";

        postgresShell = pkgs.mkShell {
          name = "postgresql-dev";

          buildInputs = with pkgs; [
            postgresql
            pgcli
          ];

          shellHook = let
            portStr = builtins.toString port;
          in ''
            # Variáveis de ambiente
            export PGDATA="${dataDir}"
            export PGPORT="${portStr}"
            export PGUSER="${user}"
            export PGPASSWORD="${password}"
            export PGHOST="${socketDir}"
            export PGDATABASE="postgres"

            mkdir -p "$PGDATA" "$PGHOST"

            if [ ! -f "$PGDATA/postgresql.conf" ]; then
              echo "📦 Inicializando cluster PostgreSQL em $PGDATA..."
              initdb -D "$PGDATA" --auth=trust --username="$PGUSER"
              echo "unix_socket_directories = '$PGHOST'" >> "$PGDATA/postgresql.conf"
              echo "port = $PGPORT" >> "$PGDATA/postgresql.conf"
              echo "✅ Cluster inicializado."
            fi

            pg-start() {
              if pg_ctl status -D "$PGDATA" >/dev/null 2>&1; then
                echo "⚠️  PostgreSQL já está rodando."
                return 0
              fi
              echo "🚀 Iniciando PostgreSQL na porta $PGPORT (socket em $PGHOST)..."
              pg_ctl start -D "$PGDATA" -o "-p $PGPORT -k $PGHOST" -l "$PGDATA/server.log"
              sleep 1
              if pg_ctl status -D "$PGDATA" >/dev/null 2>&1; then
                echo "✅ PostgreSQL iniciado com sucesso."
              else
                echo "❌ Falha ao iniciar. Verifique logs em $PGDATA/server.log"
              fi
            }

            pg-stop() {
              if ! pg_ctl status -D "$PGDATA" >/dev/null 2>&1; then
                echo "⚠️  PostgreSQL não está rodando."
                return 0
              fi
              echo "🛑 Parando PostgreSQL..."
              pg_ctl stop -D "$PGDATA" -m fast
              echo "✅ PostgreSQL parado."
            }

            pg-status() {
              if pg_ctl status -D "$PGDATA" >/dev/null 2>&1; then
                echo "✅ PostgreSQL está rodando (porta $PGPORT, socket $PGHOST)"
              else
                echo "❌ PostgreSQL não está rodando."
              fi
            }

            pg-connect() {
              local db="$1"
              if [ -z "$db" ]; then
                db="$PGDATABASE"
              fi
              if command -v pgcli &> /dev/null; then
                pgcli -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" "$db"
              else
                psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db"
              fi
            }

            pg-create-db() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: pg-create-db <nome_do_banco>"
                return 1
              fi
              psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "CREATE DATABASE $db;" 2>/dev/null && echo "✅ Banco '$db' criado." || echo "ℹ️  Banco '$db' já existe ou erro ao criar."
            }

            pg-list-dbs() {
              psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "\l"
            }

            pg-exec-sql() {
              local db="$1"
              local file="$2"
              if [ -z "$db" ] || [ -z "$file" ]; then
                echo "Uso: pg-exec-sql <banco> <arquivo.sql>"
                return 1
              fi
              psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$db" -f "$file"
              echo "✅ SQL executado em '$db'."
            }

            alias pstart='pg-start'
            alias pstop='pg-stop'
            alias pstatus='pg-status'
            alias pconnect='pg-connect'
            alias pcreatedb='pg-create-db'
            alias plist='pg-list-dbs'
            alias pexec='pg-exec-sql'

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🐘 PostgreSQL Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 PostgreSQL: $(psql --version | head -n 1)"
            echo "📦 pgcli:      $(pgcli --version 2>/dev/null || echo 'instalado')"
            echo "📁 Dados:      $PGDATA"
            echo "🔌 Socket:     $PGHOST"
            echo "🌐 Porta:      $PGPORT"
            echo "👤 Usuário:    $PGUSER (sem senha, trust)"
            echo ""
            echo "🔧 Comandos disponíveis:"
            echo "   • pg-start   (pstart)  - Inicia o servidor"
            echo "   • pg-stop    (pstop)   - Para o servidor"
            echo "   • pg-status  (pstatus) - Verifica status"
            echo "   • pg-connect [db] (pconnect) - Conecta via pgcli"
            echo "   • pg-create-db <db> (pcreatedb) - Cria banco"
            echo "   • pg-list-dbs (plist) - Lista bancos"
            echo "   • pg-exec-sql <db> <arquivo.sql> (pexec) - Executa SQL"
            echo ""
            echo "💡 Dica: O servidor NÃO inicia automaticamente. Use 'pstart' para iniciar."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      in {
        devShells = {
          default = postgresShell;
          postgresql = postgresShell;
        };
      }
    );
}
