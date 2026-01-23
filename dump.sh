#!/usr/bin/env bash
# =============================================================================
# ... (cabeçalho e variáveis iguais ao anterior) ...
# =============================================================================

set -euo pipefail

# Extensões...
EXTENSOES=( "*.nix" "*.json" "*.css" "*.conf" )
DUMP_FILE="DUMP.log"

# Cores...
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# =============================================================================
# Geração do dump (igual ao anterior)
# =============================================================================

echo "Gerando ${DUMP_FILE}..."

: > "$DUMP_FILE"

find . -type f \
    \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) \
    -not -path "*/.git/*" \
    -not -path "*/.github/*" \
    -not -name "*.bak" \
    | sort \
    | while read -r arquivo; do
        caminho_relativo="${arquivo#./}"
        {
            echo "# ----------"
            echo "# $caminho_relativo"
            echo "# ----------"
            echo ""
            cat "$arquivo"
            echo ""
            echo ""
        } >> "$DUMP_FILE"
    done

echo -e "${GREEN}Dump gerado em:${NC} $DUMP_FILE"
echo "Arquivos incluídos: $(find . -type f \( -name "*.nix" -o -name "*.json" -o -name "*.css" -o -name "*.conf" \) -not -path "*/.git/*" -not -path "*/.github/*" -not -name "*.bak" | wc -l)"
