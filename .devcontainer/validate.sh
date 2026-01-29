#!/bin/bash
# Script para validar o ambiente DevContainer/Codespace
# Uso: bash .devcontainer/validate.sh

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
PASSED=0
FAILED=0
WARNINGS=0

# Funções auxiliares
print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_test() {
    echo -e "🔍 Testing: $1"
}

print_success() {
    echo -e "${GREEN}✅ PASS${NC}: $1"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}❌ FAIL${NC}: $1"
    ((FAILED++))
}

print_warning() {
    echo -e "${YELLOW}⚠️  WARN${NC}: $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ️  INFO${NC}: $1"
}

# Banner
clear
echo -e "${BLUE}"
cat << "EOF"
╔══════════════════════════════════════════════════╗
║                                                  ║
║     NixOS Config DevContainer Validator          ║
║                                                  ║
╚══════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 1. Detectar ambiente
print_header "1️⃣  Detecção de Ambiente"

if [ -n "$CODESPACES" ]; then
    print_success "Rodando no GitHub Codespaces"
    print_info "Codespace name: $CODESPACE_NAME"
elif [ -n "$REMOTE_CONTAINERS" ] || [ -n "$VSCODE_REMOTE_CONTAINERS_SESSION" ]; then
    print_success "Rodando em DevContainer"
else
    print_warning "Não detectado Codespace/DevContainer (pode ser ambiente local)"
fi

print_info "User: $(whoami)"
print_info "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
print_info "Architecture: $(uname -m)"

# 2. Validar Nix
print_header "2️⃣  Validação do Nix"

print_test "Nix instalado"
if command -v nix &> /dev/null; then
    NIX_VERSION=$(nix --version)
    print_success "Nix encontrado: $NIX_VERSION"
else
    print_fail "Nix não encontrado no PATH"
    echo -e "\n${RED}ERRO CRÍTICO: Nix não instalado. Execute: bash .devcontainer/setup.sh${NC}\n"
    exit 1
fi

print_test "Experimental features (flakes)"
if nix flake --help &> /dev/null; then
    print_success "Flakes habilitados"
else
    print_fail "Flakes não habilitados"
fi

print_test "Configuração Nix"
if [ -f ~/.config/nix/nix.conf ]; then
    print_success "Arquivo de configuração existe"
    if grep -q "experimental-features.*flakes" ~/.config/nix/nix.conf; then
        print_success "Flakes configurado em nix.conf"
    else
        print_warning "Flakes não encontrado em nix.conf"
    fi
else
    print_warning "~/.config/nix/nix.conf não existe"
fi

# 3. Validar Git
print_header "3️⃣  Validação do Git e GitHub CLI"

print_test "Git instalado"
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "$GIT_VERSION"
else
    print_fail "Git não encontrado"
fi

print_test "GitHub CLI instalado"
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -n1)
    print_success "$GH_VERSION"
else
    print_warning "GitHub CLI não encontrado (não crítico)"
fi

# 4. Validar Flake
print_header "4️⃣  Validação do Flake NixOS"

print_test "Arquivo flake.nix existe"
if [ -f flake.nix ]; then
    print_success "flake.nix encontrado"
else
    print_fail "flake.nix não encontrado no diretório atual"
fi

print_test "Metadados do flake"
if timeout 30 nix flake metadata . &> /dev/null; then
    print_success "Flake metadata carregado com sucesso"
else
    print_fail "Erro ao carregar flake metadata (timeout ou erro)"
fi

print_test "Verificação de sintaxe"
if timeout 60 nix flake check --no-build &> /dev/null 2>&1; then
    print_success "Flake check passou (sem build)"
else
    print_warning "Flake check falhou ou demorou demais (pode ser normal em primeiro run)"
fi

# 5. Validar Devshells
print_header "5️⃣  Validação dos Devshells"

print_test "Listagem de devshells disponíveis"
DEVSHELLS=$(nix flake show . 2>&1 | grep -E "devShells\." | wc -l)
if [ "$DEVSHELLS" -gt 0 ]; then
    print_success "Encontrados $DEVSHELLS devshells"
    echo -e "\n${BLUE}Devshells disponíveis:${NC}"
    nix flake show . 2>&1 | grep "devShells\." | head -n 10 | sed 's/^/  /'
else
    print_warning "Nenhum devshell encontrado (pode demorar no primeiro run)"
fi

print_test "Teste de entrada em devshell básico"
if timeout 60 nix develop .#rust --command echo "OK" &> /dev/null; then
    print_success "Devshell rust acessível"
elif timeout 60 nix develop .#go --command echo "OK" &> /dev/null; then
    print_success "Devshell go acessível"
elif timeout 60 nix develop .#nix-dev --command echo "OK" &> /dev/null; then
    print_success "Devshell nix-dev acessível"
else
    print_warning "Não conseguiu acessar devshells (pode demorar em primeiro build)"
fi

# 6. Validar direnv
print_header "6️⃣  Validação do direnv"

print_test "direnv instalado"
if command -v direnv &> /dev/null; then
    print_success "direnv encontrado"
else
    print_warning "direnv não instalado (opcional mas recomendado)"
fi

print_test "Hook do direnv no bashrc"
if grep -q "direnv hook bash" ~/.bashrc; then
    print_success "Hook do direnv configurado"
else
    print_warning "Hook do direnv não encontrado em ~/.bashrc"
fi

# 7. Validar ferramentas opcionais
print_header "7️⃣  Ferramentas Opcionais"

print_test "nixpkgs-fmt (formatter)"
if nix-shell -p nixpkgs-fmt --run "nixpkgs-fmt --version" &> /dev/null; then
    print_success "nixpkgs-fmt disponível"
else
    print_warning "nixpkgs-fmt não disponível (não crítico)"
fi

print_test "nil (language server)"
if command -v nil &> /dev/null; then
    print_success "nil encontrado"
else
    print_warning "nil não instalado (extensão VS Code pode instalar)"
fi

# 8. Validar configurações específicas
print_header "8️⃣  Configurações NixOS do Projeto"

print_test "Hosts definidos no flake"
HOSTS=$(grep -E "nixosConfigurations\." flake.nix | grep -oP '(?<=\.)[\w-]+(?=\s*=)' 2>/dev/null || true)
if [ -n "$HOSTS" ]; then
    print_success "Hosts encontrados: $(echo $HOSTS | tr '\n' ' ')"
else
    print_warning "Nenhum host definido em nixosConfigurations"
fi

print_test "Diretórios importantes"
for DIR in "hosts" "modules" "hardware"; do
    if [ -d "$DIR" ]; then
        print_success "Diretório $DIR/ existe"
    else
        print_warning "Diretório $DIR/ não encontrado"
    fi
done

# 9. Performance e Cache
print_header "9️⃣  Performance e Cache"

print_test "Espaço em disco"
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}')
print_info "Uso do disco: $DISK_USAGE"

print_test "Nix store"
if [ -d /nix/store ]; then
    STORE_SIZE=$(du -sh /nix/store 2>/dev/null | cut -f1)
    print_success "Nix store existe (tamanho: ${STORE_SIZE:-unknown})"
else
    print_warning "Nix store não encontrado em /nix/store"
fi

# 10. Resumo Final
print_header "📊 Resumo da Validação"

TOTAL=$((PASSED + FAILED + WARNINGS))
PASS_RATE=$((PASSED * 100 / TOTAL))

echo -e "${GREEN}✅ Passou: $PASSED${NC}"
echo -e "${RED}❌ Falhou: $FAILED${NC}"
echo -e "${YELLOW}⚠️  Avisos: $WARNINGS${NC}"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Total de testes: $TOTAL"
echo -e "Taxa de sucesso: ${PASS_RATE}%\n"

# Status final
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}🎉 DevContainer validado com sucesso!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}📚 Próximos passos:${NC}"
    echo -e "  • Listar outputs: ${YELLOW}nix flake show${NC}"
    echo -e "  • Entrar em devshell: ${YELLOW}nix develop .#rust${NC}"
    echo -e "  • Verificar configuração: ${YELLOW}nix flake check${NC}"
    echo -e "  • Atualizar inputs: ${YELLOW}nix flake update${NC}\n"
    
    exit 0
elif [ $FAILED -le 2 ] && [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}⚠️  DevContainer funcional com avisos${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    echo -e "Considere revisar os avisos acima.\n"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}❌ Validação falhou - corrija os erros acima${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
    
    echo -e "${BLUE}💡 Dicas de troubleshooting:${NC}"
    echo -e "  • Execute o setup: ${YELLOW}bash .devcontainer/setup.sh${NC}"
    echo -e "  • Recarregue shell: ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  • Veja README: ${YELLOW}cat .devcontainer/README.md${NC}\n"
    
    exit 1
fi
