# DevContainer Configuration

Esta configuração permite desenvolver e testar a configuração NixOS em um GitHub Codespace ou outro ambiente DevContainer.

## 🎯 O que inclui

- **Nix com Flakes** habilitado
- **Git** e **GitHub CLI**
- **direnv** para auto-ativação de devshells
- **Extensões VS Code** para desenvolvimento Nix

## 🚀 Usando no GitHub Codespaces

1. Abra o repositório no GitHub
2. Clique em **Code** → **Codespaces** → **Create codespace on REFACTORv2**
3. Aguarde o container ser criado (primeira vez pode demorar ~5min)
4. O Nix será instalado automaticamente via setup script

## 💻 Comandos disponíveis

### Listar devshells disponíveis
```bash
nix flake show
```

### Ativar um devshell
```bash
# Rust
nix develop .#rust

# Go
nix develop .#go

# PostgreSQL
nix develop .#postgresql

# Todos os bancos
nix develop .#databases
```

### Usar direnv (auto-ativação)
```bash
# No diretório do projeto
echo "use flake .#rust" > .envrc
direnv allow

# Agora o shell é ativado automaticamente ao entrar no diretório!
```

## 🛠️ Testando configurações

```bash
# Verificar sintaxe do flake
nix flake check

# Ver metadados
nix flake metadata

# Avaluar uma configuração
nix eval .#nixosConfigurations.dell.config.system.stateVersion
```

## 🔄 Atualizando o DevContainer

Se você modificar `.devcontainer/devcontainer.json`:

1. **No VS Code**: Command Palette → "Rebuild Container"
2. **No Codespace**: Recrie o Codespace

## 📝 Notas

- O Nix é instalado em modo **single-user** (não requer root)
- Flakes estão habilitados por padrão
- O cache de builds é local ao container (não persiste entre rebuilds)
- Para persistência, use volumes ou GitHub Codespaces prebuilds

## 🐛 Troubleshooting

### Comando `nix` não encontrado após setup

```bash
# Recarregue o shell
source ~/.bashrc

# Ou verifique se o Nix está no PATH
echo $PATH | grep nix
```

### Erro de experimental features

```bash
# Adicione às suas configurações
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### DevShell não encontrado

```bash
# Atualize os inputs do flake
nix flake update

# Limpe o cache
nix flake lock --update-input nixpkgs-stable
```
