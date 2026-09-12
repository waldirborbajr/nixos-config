{
  description = "MongoDB development environment (binary, pre-built)";

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
        # Importamos o nixpkgs permitindo pacotes unfree (MongoDB)
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Use uma versão com cache garantido, ou 'mongodb' para a mais recente
        # Se quiser a mais recente, use 'mongodb'. Se quiser uma estável, use 'mongodb-6_0' ou 'mongodb-5_0'.
        mongoPkg = pkgs.mongodb; # ou pkgs.mongodb-6_0

        dataDir = "$HOME/.local/mongodb/data";
        logDir = "$HOME/.local/mongodb/log";
        pidFile = "$HOME/.local/mongodb/mongod.pid";
        port = 27017;

        mongodbShell = pkgs.mkShell {
          name = "mongodb-dev";

          buildInputs = with pkgs; [
            mongoPkg
            mongosh
          ];

          shellHook = let
            portStr = builtins.toString port;
          in ''
            export MONGODB_DATA="${dataDir}"
            export MONGODB_LOG="${logDir}"
            export MONGODB_PORT="${portStr}"
            export MONGODB_PID="${pidFile}"

            mkdir -p "${dataDir}" "${logDir}"

            mongo-start() {
              if [ -f "$MONGODB_PID" ] && kill -0 "$(cat "$MONGODB_PID")" 2>/dev/null; then
                echo "⚠️  MongoDB já está rodando (PID $(cat $MONGODB_PID))."
                return 0
              fi
              echo "🚀 Iniciando MongoDB na porta $MONGODB_PORT..."
              mongod --dbpath "$MONGODB_DATA" --logpath "$MONGODB_LOG/mongod.log" --port "$MONGODB_PORT" --pidfilepath "$MONGODB_PID" --fork
              sleep 2
              if [ -f "$MONGODB_PID" ] && kill -0 "$(cat "$MONGODB_PID")" 2>/dev/null; then
                echo "✅ MongoDB iniciado (PID $(cat $MONGODB_PID))."
              else
                echo "❌ Falha ao iniciar. Veja $MONGODB_LOG/mongod.log"
              fi
            }

            mongo-stop() {
              if [ ! -f "$MONGODB_PID" ]; then
                echo "⚠️  MongoDB não está rodando."
                return 0
              fi
              local PID=$(cat "$MONGODB_PID")
              if kill -0 "$PID" 2>/dev/null; then
                echo "🛑 Parando MongoDB (PID $PID)..."
                kill "$PID"
                sleep 1
                echo "✅ MongoDB parado."
              else
                rm -f "$MONGODB_PID"
              fi
            }

            mongo-status() {
              if [ -f "$MONGODB_PID" ] && kill -0 "$(cat "$MONGODB_PID")" 2>/dev/null; then
                echo "✅ MongoDB rodando (PID $(cat $MONGODB_PID), porta $MONGODB_PORT)."
              else
                echo "❌ MongoDB não está rodando."
              fi
            }

            mongo-connect() {
              mongosh --port "$MONGODB_PORT"
            }

            mongo-create-db() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: mongo-create-db <nome_banco>"
                return 1
              fi
              mongosh --port "$MONGODB_PORT" --eval "db.getSiblingDB('$db').createCollection('_init')" >/dev/null 2>&1
              echo "✅ Banco '$db' criado (ou já existente)."
            }

            mongo-list-dbs() {
              mongosh --port "$MONGODB_PORT" --eval "db.adminCommand('listDatabases').databases.forEach(d => print(d.name))"
            }

            mongo-exec() {
              local file="$1"
              if [ -z "$file" ]; then
                echo "Uso: mongo-exec <arquivo.js>"
                return 1
              fi
              mongosh --port "$MONGODB_PORT" --file "$file"
            }

            mongo-seed() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: mongo-seed <nome_banco>"
                return 1
              fi
              mongosh --port "$MONGODB_PORT" --eval "
                db = db.getSiblingDB('$db');
                db.users.insertMany([
                  { name: 'Alice', age: 30 },
                  { name: 'Bob', age: 25 },
                  { name: 'Charlie', age: 35 }
                ]);
                print('Dados inseridos em $db.users');
              "
            }

            alias mstart='mongo-start'
            alias mstop='mongo-stop'
            alias mstatus='mongo-status'
            alias mconnect='mongo-connect'
            alias mcreatedb='mongo-create-db'
            alias mlist='mongo-list-dbs'
            alias mexec='mongo-exec'
            alias mseed='mongo-seed'

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🍃 MongoDB Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 MongoDB: $(mongod --version | head -n 1)"
            echo "📦 mongosh:  $(mongosh --version 2>/dev/null | head -n 1 || echo 'instalado')"
            echo "📁 Dados:    $MONGODB_DATA"
            echo "📁 Logs:     $MONGODB_LOG"
            echo "🌐 Porta:    $MONGODB_PORT"
            echo "🔒 Autenticação: desabilitada (ambiente dev)"
            echo ""
            echo "🔧 Comandos: mstart, mstop, mstatus, mconnect, mcreatedb <db>, mlist, mexec <file>, mseed <db>"
            echo "💡 O Nix já baixou o binário pré‑compilado – a primeira execução pode demorar um pouco, mas as próximas serão instantâneas."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      in {
        devShells = {
          default = mongodbShell;
          mongodb = mongodbShell;
        };
      }
    );
}
