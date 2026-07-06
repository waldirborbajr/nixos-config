<h1>
❄️ NixOS - BORBA JR, W - Configuration ❄️
</h1>

## 🖥️ Supported Hardware

### 🍎 MacBook Pro 13" (2011)
- Architecture: x86_64
- RAM: 16 GB
- Storage: 500 GB SSD
- Role: main workstation
- Desktop: Niri & GNOME (Wayland via GDM)
- Optional features: DEVOPS / QEMU (on-demand)

### 💻 Dell Inspiron 1456
- Architecture: x86_64
- RAM: 4 GB
- Storage: 120 GB SSD
- Role: basic usage / study machine
- Desktop: i3 (X11)
- Optional features: all disabled (Docker, K3s, QEMU)

## 🛠️ Development Shells

This flake includes **devShells** for isolated development environments:

```bash
# Rust stable + complete toolchain
nix develop .#rust

# Rust nightly via fenix
nix develop .#rust-nightly

# Go + gopls + delve + tools
nix develop .#go

# Lua + LuaJIT + LSP
nix develop .#lua

# Nix development (formatters, LSPs, linters)
nix develop .#nix-dev

# Full stack (Rust + Go + Node)
nix develop .#fullstack

# Default (basic)
nix develop
```

**Advantages:**
- ✅ Isolated environments per project
- ✅ Specific tool versions
- ✅ Reproducible across machines
- ✅ Doesn't pollute global system

**Languages available globally:**
- Go (`modules/languages/go.nix`)
- Rust (`modules/languages/rust.nix`)
- Lua (`modules/languages/lua.nix` - toggle)
- Nix (`modules/languages/nix-dev.nix`)
- Python, Node.js

## 🔐 SSH keys via SOPS

Este repositório agora prepara automaticamente duas identidades SSH para o usuário `borba`:

- `id_ed25519_infra`: usada para acesso SSH entre servidores e relação de confiança
- `id_ed25519_github`: usada para GitHub, GitLab, Forgejo e outros repositórios remotos

Fluxo simples:

```bash
./scripts/manage-ssh-sops.sh dell1456
sudo nixos-rebuild switch --flake .#dell1456
```

O script gera as chaves se necessário, cria uma chave Age local quando ainda não existir e cifra as chaves no arquivo de secrets do host correspondente em `hosts/<host>/secrets/<host>.yaml`.

```text
https://git.voidarc.co.uk/voidarc/nixos
```


