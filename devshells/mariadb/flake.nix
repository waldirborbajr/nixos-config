{
  description = "MariaDB standalone development environment";

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

        dataDir = "$HOME/.local/mariadb/data";
        socketDir = "$HOME/.local/mariadb";
        socketFile = "$socketDir/mysql.sock";
        pidFile = "$dataDir/mariadb.pid";
        port = 3306;
        user = "root";
        password = "";

        mariadbShell = pkgs.mkShell {
          name = "mariadb-dev";

          buildInputs = with pkgs; [
            mariadb
            mycli
          ];

          shellHook = let
            portStr = builtins.toString port;
          in ''
            # Configuração
            export MARIADB_DATA="${dataDir}"
            export MARIADB_SOCKET="${socketFile}"
            export MARIADB_PORT="${portStr}"
            export MARIADB_USER="${user}"
            export MARIADB_PASSWORD="${password}"

            # Garantir diretórios
            mkdir -p "${dataDir}" "${socketDir}"

            # Inicializar se necessário
            if [ ! -f "${dataDir}/mysql/user.frm" ]; then
              echo "📦 Inicializando diretório de dados em ${dataDir}..."
              mariadb-install-db --datadir="${dataDir}" --user="$(whoami)" --auth-root-authentication-method=normal
              echo "✅ Diretório inicializado."
            fi

            # Função para iniciar o servidor
            mariadb-start() {
              if [ -f "${pidFile}" ] && kill -0 "$(cat "${pidFile}")" 2>/dev/null; then
                echo "⚠️  MariaDB já está rodando (PID $(cat ${pidFile}))."
                return 0
              fi
              echo "🚀 Iniciando MariaDB..."
              mysqld_safe --datadir="${dataDir}" --socket="${socketFile}" --port="${portStr}" --pid-file="${pidFile}" --skip-networking=0 &
              sleep 2
              if [ -f "${pidFile}" ] && kill -0 "$(cat "${pidFile}")" 2>/dev/null; then
                echo "✅ MariaDB iniciado na porta ${portStr} (socket ${socketFile})"
              else
                echo "❌ Falha ao iniciar MariaDB. Verifique logs em ${dataDir}/*.err"
              fi
            }

            # Função para parar
            mariadb-stop() {
              if [ ! -f "${pidFile}" ]; then
                echo "⚠️  MariaDB não está rodando (arquivo PID não encontrado)."
                return 0
              fi
              local PID=$(cat "${pidFile}")
              if kill -0 $PID 2>/dev/null; then
                echo "🛑 Parando MariaDB (PID $PID)..."
                kill $PID
                sleep 1
                echo "✅ MariaDB parado."
              else
                echo "⚠️  PID $PID não está ativo. Removendo arquivo PID."
                rm -f "${pidFile}"
              fi
            }

            # Função para status
            mariadb-status() {
              if [ -f "${pidFile}" ] && kill -0 "$(cat "${pidFile}")" 2>/dev/null; then
                echo "✅ MariaDB está rodando (PID $(cat ${pidFile}), porta ${portStr}, socket ${socketFile})"
              else
                echo "❌ MariaDB não está rodando."
              fi
            }

            # Função para conectar (mycli ou mysql)
            mariadb-connect() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: mariadb-connect <banco>"
                return 1
              fi
              if command -v mycli &> /dev/null; then
                mycli -h localhost -P "${portStr}" -u "${user}" -p"${password}" "$db"
              else
                mysql -h localhost -P "${portStr}" -u "${user}" -p"${password}" "$db"
              fi
            }

            # Função para criar banco
            mariadb-create-db() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: mariadb-create-db <nome_do_banco>"
                return 1
              fi
              mysql -h localhost -P "${portStr}" -u "${user}" -p"${password}" -e "CREATE DATABASE IF NOT EXISTS $db;"
              echo "✅ Banco '$db' criado (ou já existente)."
            }

            # Função para listar bancos
            mariadb-list-dbs() {
              mysql -h localhost -P "${portStr}" -u "${user}" -p"${password}" -e "SHOW DATABASES;"
            }

            # Função para executar SQL
            mariadb-exec-sql() {
              local db="$1"
              local file="$2"
              if [ -z "$db" ] || [ -z "$file" ]; then
                echo "Uso: mariadb-exec-sql <banco> <arquivo.sql>"
                return 1
              fi
              mysql -h localhost -P "${portStr}" -u "${user}" -p"${password}" "$db" < "$file"
              echo "✅ SQL executado em '$db'."
            }

            # Atalhos
            alias mstart='mariadb-start'
            alias mstop='mariadb-stop'
            alias mstatus='mariadb-status'
            alias mconnect='mariadb-connect'
            alias mcreatedb='mariadb-create-db'
            alias mlist='mariadb-list-dbs'
            alias mexec='mariadb-exec-sql'

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🗄️  MariaDB Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 MariaDB: $(mariadb --version | head -n 1)"
            echo "📦 mycli:    $(mycli --version 2>/dev/null || echo 'instalado')"
            echo "📁 Dados:    ${dataDir}"
            echo "🔌 Socket:   ${socketFile}"
            echo "🌐 Porta:    ${portStr}"
            echo "👤 Usuário:  ${user} (sem senha)"
            echo ""
            echo "🔧 Comandos disponíveis:"
            echo "   • mariadb-start   (mstart)  - Inicia o servidor"
            echo "   • mariadb-stop    (mstop)   - Para o servidor"
            echo "   • mariadb-status  (mstatus) - Verifica status"
            echo "   • mariadb-connect <db> (mconnect) - Conecta via mycli"
            echo "   • mariadb-create-db <db> (mcreatedb) - Cria banco"
            echo "   • mariadb-list-dbs (mlist) - Lista bancos"
            echo "   • mariadb-exec-sql <db> <arquivo.sql> (mexec) - Executa SQL"
            echo ""
            echo "💡 Dica: O servidor NÃO inicia automaticamente. Use 'mstart' para iniciar."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      in {
        devShells = {
          default = mariadbShell;
          mariadb = mariadbShell;
        };
      }
    );
}
