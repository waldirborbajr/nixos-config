#!/usr/bin/env bash
# =============================================================================
# Adiciona cabeçalho com caminho relativo em arquivos .nix .json .css .conf
# Ignora .git, .github e arquivos .bak
# Gera dump no final em DUMP.log
# =============================================================================

set -euo pipefail

# Extensões que vamos processar
EXTENSOES=( "*.nix" "*.json" "*.css" "*.conf" )

# Arquivo de saída final
DUMP_FILE="DUMP.log"

# Cores para output (opcional)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# =============================================================================
# Função principal de processamento de um arquivo
# =============================================================================
processar_arquivo() {
    local arquivo="$1"
    local caminho_relativo="${arquivo#./}"

    # Comentário esperado (padrão por extensão)
    case "${arquivo##*.}" in
        nix)  prefixo="# " ;;
        json) prefixo="// " ;;
        css)  prefixo="/* "  sufixo=" */" ;;
        conf) prefixo="# " ;;
        *)    prefixo="# " ;;   # fallback
    esac

    linha_esperada="${prefixo}${caminho_relativo}${sufixo:-}"

    echo -e "${YELLOW}Verificando:${NC} $caminho_relativo"

    if [ ! -s "$arquivo" ]; then
        echo -e "  → ${RED}Arquivo vazio → será processado${NC}"
    else
        primeira_linha=$(head -n 1 "$arquivo")
        # Remove espaços iniciais e finais para comparação mais confiável
        primeira_linha_limpa="${primeira_linha#"${primeira_linha%%[![:space:]]*}"}"
        primeira_linha_limpa="${primeira_linha_limpa%"${primeira_linha_limpa##*[![:space:]]}"}"

        if [[ "$primeira_linha_limpa" == "${linha_esperada}"* ]]; then
            echo -e "  → ${GREEN}Já contém o cabeçalho esperado → pulando${NC}"
            return 0
        fi
    fi

    # Se chegou aqui → precisa modificar
    echo -e "  → ${GREEN}Inserindo cabeçalho:${NC}"
    echo "     $linha_esperada"
    if [[ -n "${sufixo:-}" ]]; then
        echo "     ${prefixo}---${sufixo}"
    else
        echo "     ${prefixo}---"
    fi

    # Backup apenas se for modificar
    cp -p "$arquivo" "${arquivo}.bak"

    # Insere no topo (GNU sed)
    if [[ -n "${sufixo:-}" ]]; then
        # Para CSS com /* ... */
        sed -i "1i ${prefixo}---${sufixo}" "$arquivo"
        sed -i "1i ${linha_esperada}" "$arquivo"
    else
        sed -i "1i ${prefixo}---" "$arquivo"
        sed -i "1i ${linha_esperada}" "$arquivo"
    fi

    echo -e "  → ${GREEN}Feito.${NC}\n"
}

# =============================================================================
# Programa principal
# =============================================================================

echo "Buscando arquivos: ${EXTENSOES[*]}"
echo "Ignorando: .git/, .github/, *.bak"

# Remove backups antigos (se existirem)
find . -type f -name "*.bak" -delete 2>/dev/null || true

# Processa todos os arquivos das extensões desejadas
for padrao in "${EXTENSOES[@]}"; do
    find . -type f -name "$padrao" \
        -not -path "*/.git/*" \
        -not -path "*/.github/*" \
        -print0 | while IFS= read -r -d '' arquivo; do
            processar_arquivo "$arquivo"
        done
done

echo -e "\n${GREEN}Todos os arquivos foram processados.${NC}"
echo -e "Backups (.bak) foram removidos.\n"

# =============================================================================
# Geração do DUMP final
# =============================================================================

echo "Gerando dump em → $DUMP_FILE"

# Limpa arquivo de saída
: > "$DUMP_FILE"

# Lista todos os arquivos que processamos (exceto .git/.github e .bak)
find . -type f \
    \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) \
    -not -path "*/.git/*" \
    -not -path "*/.github/*" \
    -not -name "*.bak" \
    | sort \
    | while read -r arquivo; do
        caminho_relativo="${arquivo#./}"
        
        {
            echo "═══════════════════════════════════════════════════════════════"
            echo "$caminho_relativo"
            echo "═══════════════════════════════════════════════════════════════"
            echo ""
            cat "$arquivo"
            echo ""
            echo ""
        } >> "$DUMP_FILE"
    done

echo -e "${GREEN}Dump gerado com sucesso em:${NC} $DUMP_FILE"
echo "Total de arquivos incluídos: $(wc -l < <(find . -type f \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) -not -path "*/.git/*" -not -path "*/.github/*" -not -name "*.bak"))"
