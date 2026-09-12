{
  description = "SQLite standalone development environment";

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

        sqliteShell = pkgs.mkShell {
          name = "sqlite-dev";

          buildInputs = with pkgs; [
            sqlite # CLI e biblioteca
            sqlite-analyzer # Análise de banco
            # sqlite-docs não existe como pacote separado – removido
            # sqlite-interactive também não é um pacote – removido
          ];

          shellHook = ''
            # Variáveis de ambiente (opcionais)
            export SQLITE_HOME="$HOME/.local/sqlite"
            mkdir -p "$SQLITE_HOME"

            # Função: criar um novo banco
            sql-create() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: sql-create <nome_do_banco.db>"
                return 1
              fi
              if [ -f "$db" ]; then
                echo "⚠️  Banco '$db' já existe."
                return 1
              fi
              sqlite3 "$db" "VACUUM;"  # cria um banco vazio
              echo "✅ Banco '$db' criado."
            }

            # Função: conectar (modo interativo)
            sql-connect() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: sql-connect <banco.db>"
                return 1
              fi
              sqlite3 -header -column "$db"
            }

            # Função: executar uma consulta SQL
            sql-query() {
              local db="$1"
              local query="$2"
              if [ -z "$db" ] || [ -z "$query" ]; then
                echo "Uso: sql-query <banco.db> \"<consulta SQL>\""
                return 1
              fi
              sqlite3 -header -column "$db" "$query"
            }

            # Função: executar um arquivo SQL
            sql-exec() {
              local db="$1"
              local file="$2"
              if [ -z "$db" ] || [ -z "$file" ]; then
                echo "Uso: sql-exec <banco.db> <arquivo.sql>"
                return 1
              fi
              sqlite3 "$db" < "$file"
              echo "✅ SQL executado em '$db'."
            }

            # Função: listar tabelas
            sql-tables() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: sql-tables <banco.db>"
                return 1
              fi
              sqlite3 "$db" ".tables"
            }

            # Função: mostrar schema
            sql-schema() {
              local db="$1"
              local table="$2"
              if [ -z "$db" ]; then
                echo "Uso: sql-schema <banco.db> [tabela]"
                return 1
              fi
              if [ -z "$table" ]; then
                sqlite3 "$db" ".schema"
              else
                sqlite3 "$db" ".schema $table"
              fi
            }

            # Função: analisar banco
            sql-analyze() {
              local db="$1"
              if [ -z "$db" ]; then
                echo "Uso: sql-analyze <banco.db>"
                return 1
              fi
              sqlite3_analyzer "$db"
            }

            # Função: backup (dump SQL)
            sql-dump() {
              local db="$1"
              local output="$2"
              if [ -z "$db" ] || [ -z "$output" ]; then
                echo "Uso: sql-dump <banco.db> <arquivo.sql>"
                return 1
              fi
              sqlite3 "$db" ".dump" > "$output"
              echo "✅ Backup salvo em '$output'."
            }

            # Atalhos rápidos
            alias screate='sql-create'
            alias sconnect='sql-connect'
            alias squery='sql-query'
            alias sexec='sql-exec'
            alias stables='sql-tables'
            alias sschema='sql-schema'
            alias sanalyze='sql-analyze'
            alias sdump='sql-dump'

            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "🔷 SQLite Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "📦 SQLite: $(sqlite3 --version | head -n 1)"
            echo "📦 sqlite-analyzer: $(sqlite3_analyzer --version 2>/dev/null | head -n 1 || echo 'instalado')"
            echo "📁 Diretório: $SQLITE_HOME"
            echo ""
            echo "🔧 Comandos disponíveis:"
            echo "   • sql-create   (screate)  <banco.db>    - Cria um novo banco vazio"
            echo "   • sql-connect  (sconnect) <banco.db>    - Conecta interativamente"
            echo "   • sql-query    (squery)   <db> \"<sql>\" - Executa consulta SQL"
            echo "   • sql-exec     (sexec)    <db> <arquivo> - Executa script SQL"
            echo "   • sql-tables   (stables)  <db>          - Lista tabelas"
            echo "   • sql-schema   (sschema)  <db> [tabela] - Mostra schema"
            echo "   • sql-analyze  (sanalyze) <db>          - Analisa o banco"
            echo "   • sql-dump     (sdump)    <db> <arquivo> - Dump SQL"
            echo ""
            echo "💡 Dica: use 'sqlite3' diretamente ou as funções acima."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          '';
        };
      in {
        devShells = {
          default = sqliteShell;
          sqlite = sqliteShell;
        };
      }
    );
}
