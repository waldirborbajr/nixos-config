{
  description = "FerretDB development environment (MongoDB-compatible, SQLite backend)";

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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = false; # FerretDB é Apache-2.0, não precisa de unfree
        };

        dataDir = "$HOME/.local/ferretdb/data";
        logFile = "$HOME/.local/ferretdb/log/ferretdb.log";
        pidFile = "$HOME/.local/ferretdb/ferretdb.pid";
        port = 27017;

        ferretdbShell = pkgs.mkShell {
          name = "ferretdb-dev";

          buildInputs = with pkgs; [
            ferretdb
            mongosh
            sqlite # útil pra inspecionar o arquivo .sqlite diretamente
          ];

          shellHook = let
            portStr = builtins.toString port;
          in ''
            export FERRETDB_DATA="${dataDir}"
            export FERRETDB_LOGFILE="${logFile}"
            export FERRETDB_PORT="${portStr}"
            export FERRETDB_PID="${pidFile}"

            mkdir -p "$FERRETDB_DATA" "$(dirname "$FERRETDB_LOGFILE")"

            ferret-start() {
              if [ -f "$FERRETDB_PID" ] && kill -0 "$(cat "$FERRETDB_PID")" 2>/dev/null; then
                echo "⚠️  FerretDB já está rodando (PID $(cat $FERRETDB_PID))."
                return 0
              fi
              echo "🚀 Iniciando FerretDB (backend SQLite) na porta $FERRETDB_PORT..."
              FERRETDB_HANDLER=sqlite \
              FERRETDB_SQLITE_URL="file:$FERRETDB_DATA/" \
              FERRETDB_LISTEN_ADDR=":$FERRETDB_PORT" \
              FERRETDB_TELEMETRY=disable \
                ferretdb > "$FERRETDB_LOGFILE" 2>&1 &
              echo $! > "$FERRETDB_PID"
              sleep 1
              if kill -0 "$(cat "$FERRETDB_PID")" 2>/dev/null; then
                echo "✅ FerretDB iniciado (PID $(cat $FERRETDB_PID))."
              else
                echo "❌ Falha ao iniciar. Veja $FERRETDB_LOGFILE"
                rm -f "$FERRETDB_PID"
              fi
            }

            ferret-stop() {
              if [ ! -f "$FERRETDB_PID" ]; then
                echo "⚠️  FerretDB não está rodando."
                return 0
              fi
              local PID=$(cat "$FERRETDB_PID")
              if kill -0 "$PID" 2>/dev/null; then
                echo "🛑 Parando FerretDB (PID $PID)..."
                kill "$PID"
                sleep 1
                rm -f "$FERRETDB_PID"
                echo "✅ FerretDB parado."
              else
                rm -f "$FERRETDB_PID"
              fi
            }

            ferret-status() {
              if [ -f "$FERRETDB_PID" ] && kill -0 "$(cat "$FERRETDB_PID")" 2>/dev/null; then
                echo "✅ FerretDB rodando (PID $(cat $FERRETDB_PID), porta $FERRETDB_PORT, backend SQLite)."
              else
                echo "❌ FerretDB não está rodando."
              fi
            }

            ferret-connect() {
              # mongosh precisa de authMechanism=PLAIN pro handler SQLite/PG do FerretDB
              mongosh "mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN"
            }

            ferret-create-db() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: ferret-create-db <nome_banco>"
                return 1
              fi
              mongosh "mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN" \
                --eval "db.getSiblingDB('$db').createCollection('_init')" >/dev/null 2>&1
              echo "✅ Banco '$db' criado (ou já existente)."
            }

            ferret-list-dbs() {
              mongosh "mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN" \
                --eval "db.adminCommand('listDatabases').databases.forEach(d => print(d.name))"
            }

            ferret-exec() {
              local file="$1"
              if [ -z "$file" ]; then
                echo "Uso: ferret-exec <arquivo.js>"
                return 1
              fi
              mongosh "mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN" --file "$file"
            }

            ferret-seed() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: ferret-seed <nome_banco>"
                return 1
              fi
              mongosh "mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN" --eval "
                db = db.getSiblingDB('$db');
                db.users.insertMany([
                  { name: 'Alice', age: 30 },
                  { name: 'Bob', age: 25 },
                  { name: 'Charlie', age: 35 }
                ]);
                print('Dados inseridos em $db.users');
              "
            }

            alias fstart='ferret-start'
            alias fstop='ferret-stop'
            alias fstatus='ferret-status'
            alias fconnect='ferret-connect'
            alias fcreatedb='ferret-create-db'
            alias flist='ferret-list-dbs'
            alias fexec='ferret-exec'
            alias fseed='ferret-seed'

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🦫 FerretDB Development Environment (SQLite backend)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 FerretDB: $(ferretdb --version 2>/dev/null | head -n 1 || echo 'instalado')"
            echo "📦 mongosh:  $(mongosh --version 2>/dev/null | head -n 1 || echo 'instalado')"
            echo "📁 Dados:    $FERRETDB_DATA (arquivos .sqlite, um por database)"
            echo "📁 Log:      $FERRETDB_LOGFILE"
            echo "🌐 Porta:    $FERRETDB_PORT"
            echo "🔌 URI:      mongodb://127.0.0.1:$FERRETDB_PORT/?authMechanism=PLAIN"
            echo "🔗 Compatível com o protocolo MongoDB 5.0+ — drivers Mongo funcionam sem alteração."
            echo ""
            echo "🔧 Comandos: fstart, fstop, fstatus, fconnect, fcreatedb <db>, flist, fexec <file>, fseed <db>"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      in {
        devShells = {
          default = ferretdbShell;
          ferretdb = ferretdbShell;
        };
      }
    );
}
