# Entrar no ambiente

nix develop path:.

# Criar um banco de teste

screate meubanco.db

# Conectar interativamente

sconnect meubanco.db

# (dentro do SQLite) criar tabela, inserir, etc.

# CREATE TABLE usuarios (id INTEGER, nome TEXT);

# INSERT INTO usuarios VALUES (1, 'Alice');

# Sair do SQLite (Ctrl+D ou .quit)

# Executar uma consulta

squery meubanco.db "SELECT * FROM usuarios;"

# Executar um script SQL

sexec meubanco.db ./cria_tabelas.sql

# Listar tabelas

stables meubanco.db

# Ver schema

sschema meubanco.db usuarios

# Fazer backup

sdump meubanco.db backup.sql

# Analisar banco

sanalyze meubanco.db
