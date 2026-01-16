# ❄️ NixOS Configuration (Flakes + Home Manager)

Este repositório contém minha configuração pessoal de **NixOS**, utilizando **Flakes** e **Home Manager**, com suporte a **múltiplos hosts** e **múltiplos usuários**, mantendo uma separação clara entre:

- configuração de **sistema**
- configuração de **usuário**
- módulos **comuns**, **core**, **desktop** e **tooling**

---

## 📁 Estrutura do Repositório

```text
.
├── Makefile
├── build.sh
├── flake.nix
├── flake.lock
├── README.md
│
├── common/                  # Configuração NixOS compartilhada
│   ├── configuration.nix    # Base do sistema
│   ├── packages.nix         # systemPackages
│   ├── programs.nix         # programas globais
│   ├── fonts.nix            # fontes
│   ├── users.nix            # definição de usuários do sistema
│   └── users-data.nix       # dados dos usuários (nome, email, chaves)
│
├── hosts/                   # Hosts (máquinas)
│   ├── dell/
│   │   ├── default.nix
│   │   └── hardware-configuration.nix
│   └── macbook/
│       └── default.nix
│
└── home/                    # Home Manager
    ├── borba/               # Usuário borba
    │   └── default.nix
    │
    ├── devops/              # Usuário devops
    │   └── default.nix
    │
    └── common/              # Módulos compartilhados de Home Manager
        ├── core/            # Essenciais (CLI / shell)
        │   ├── atuin
        │   ├── bat
        │   ├── btop
        │   ├── fastfetch
        │   ├── fzf
        │   ├── gh
        │   ├── git
        │   ├── gpg
        │   ├── lazygit
        │   ├── starship
        │   ├── tmux
        │   ├── zsh
        │   └── default.nix
        │
        ├── desktop/         # Ambiente gráfico
        │   ├── alacritty
        │   ├── anydesk
        │   ├── browsers
        │   ├── telegram
        │   ├── wayland
        │   └── default.nix
        │
        ├── devtools/        # Ferramentas de desenvolvimento
        │   ├── docker
        │   ├── go
        │   ├── neovim
        │   ├── nix
        │   ├── rust
        │   └── default.nix
        │
        └── devopstools      # Ferramentas específicas de DevOps
            ├── k8s
            └── defaut.nix
```

---

## 🧠 Conceito da Estrutura

### 🔹 `common/` (NixOS)
Configuração **global do sistema**, válida para todos os hosts:

- pacotes essenciais
- usuários
- fontes
- serviços
- base do sistema

---

### 🔹 `hosts/`
Cada host importa os módulos de `common` e define apenas o que é **específico da máquina**.

Exemplo:
```bash
hosts/dell
hosts/macbook
```

---

### 🔹 `home/common/core`
Ferramentas **básicas e obrigatórias** para qualquer usuário:

- shell (zsh)
- git / gh / gpg
- tmux
- cli utilities
- prompt

---

### 🔹 `home/common/desktop`
Tudo relacionado a **ambiente gráfico / Wayland**:

- Alacritty
- Browsers
- Clipboard
- Portais
- UX / Performance
- Apps desktop

---

### 🔹 `home/common/devtools`
Ferramentas de **desenvolvimento**:

- Go + tooling
- Rust + tooling
- Neovim (config externa)
- Docker client
- Ferramentas Nix

---

### 🔹 `home/common/devopstools`
Ferramentas **exclusivas de DevOps**:

- Kubernetes
- Containers
- Cloud / Ops utilities

---

### 🔹 Usuários (`home/borba`, `home/devops`)
Cada usuário decide **quais módulos importar**:

```nix
imports = [
  ../common/core
  ../common/desktop
  ../common/devtools
  ../common/devopstools
];

home.stateVersion = "25.11";
```

---

## 🚀 Build & Deploy

### Build do sistema
```bash
sudo nixos-rebuild switch --flake .#dell
```

### Home Manager
```bash
home-manager switch --flake .#dell.borba
```

---

## ✅ Objetivos do Setup

- Modularidade máxima
- Reuso entre usuários
- Separação clara entre sistema e usuário
- Fácil manutenção
- Setup completo para desktop + dev + devops

---

## 🧊 Observações

- Flake usa `nixos-unstable`
- Catppuccin aplicado globalmente
- Rust via `rust-overlay`
- Configs de Neovim e Tmux externas, apenas *sourceadas*

---

Enjoy ❄️ NixOS
