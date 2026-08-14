#!/usr/bin/env bash
# Script para parear Logitech K380 no NixOS

echo "🔵 Preparando para parear o Logitech K380..."

# Verifica se o expect está instalado
if ! command -v expect &> /dev/null; then
    echo "❌ 'expect' não encontrado! Instale com:"
    echo "   nix-shell -p expect"
    exit 1
fi

# Coloca o teclado em modo de pareamento
echo "📌 1. Pressione e segure o botão Easy-Switch (1, 2 ou 3) por 5 segundos"
echo "   até a luz azul piscar rapidamente."
echo "   PRESSIONE ENTER QUANDO O TECLADO ESTIVER PISCANDO"
read -p ""

# Inicia o processo com expect
expect << 'EOF'
set timeout 60

# Inicia o bluetoothctl
spawn bluetoothctl

# Aguarda o prompt
expect "# "

# Configura o agente
send "agent KeyboardDisplay\r"
expect "# "

send "default-agent\r"
expect "# "

# Inicia a busca
send "scan on\r"
expect {
    "Keyboard K380" {
        # Extrai o MAC do dispositivo
        regexp {Device ([0-9A-F:]+)} $expect_out(buffer) -> mac
        send_user "✅ Teclado encontrado: $mac\n"
    }
    timeout {
        send_user "❌ Teclado não encontrado. Certifique-se que está em modo de pareamento.\n"
        exit 1
    }
}

# Para a busca
send "scan off\r"
expect "# "

# Marca como confiável
send "trust $mac\r"
expect "# "

# Tenta parear
send "pair $mac\r"
expect {
    "Enter PIN code:" {
        send_user "\n🔑 Digite o código exibido no teclado e pressione ENTER\n"
        expect_user -re "(.*)\r" {
            set pin $expect_out(1,string)
            send "$pin\r"
        }
    }
    "PIN code:" {
        send_user "\n🔑 Digite o código exibido no teclado e pressione ENTER\n"
        expect_user -re "(.*)\r" {
            set pin $expect_out(1,string)
            send "$pin\r"
        }
    }
    "Pairing successful" {
        send_user "✅ Pareamento concluído com sucesso!\n"
    }
    timeout {
        send_user "❌ Tempo esgotado para digitar o PIN.\n"
        exit 1
    }
}

expect "# "

# Conecta
send "connect $mac\r"
expect {
    "Connection successful" {
        send_user "✅ Conectado com sucesso!\n"
    }
    timeout {
        send_user "⚠️ Pareamento ok, mas conexão falhou. Tente conectar manualmente.\n"
    }
}

# Sai
send "quit\r"
expect eof
EOF

echo ""
echo "📌 Se o script falhou, tente o método manual:"
echo "   bluetoothctl"
echo "   agent KeyboardDisplay"
echo "   default-agent"
echo "   scan on"
echo "   trust [MAC]"
echo "   pair [MAC]"
echo "   (digite o PIN que aparecer na tela)"
