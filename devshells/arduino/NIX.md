# Entrar no shell

nix develop path:.

# Criar um novo sketch

new-sketch meu_projeto
cd meu_projeto

# Editar o arquivo .ino (com seu editor preferido, ex: helix)

hx meu_projeto.ino

# Compilar

compile-sketch .

# Conectar a placa e verificar a porta

list-boards

# Fazer upload (substitua /dev/ttyUSB0 pela porta correta)

upload-sketch . /dev/ttyUSB0

# Instalar uma biblioteca (ex: Servo)

install-library Servo
