# My NixOS Configuration

## ❄️ Overview

This repository contains my personal NixOS configuration, fully managed with **Nix Flakes**.  
It supports **multiple hosts** and **multiple users**, with both **system-wide configuration** and **Home Manager** configurations for each user.

---

## 📁 Structure

```text
.
├── flake.nix
├── flake.lock
├── common/
│   ├── configuration.nix
│   ├── packages.nix
│   ├── programs.nix
│   ├── fonts.nix
│   ├── users.nix
│   └── users-data.nix
│
├── home/
│   ├── common/
│   │   ├── core/
│   │   │   ├── git
│   │   │   ├── zsh
│   │   │   ├── alacritty
│   │   │   ├── tmux
│   │   │   └── default.nix
│   │   │
│   │   ├── profiles/
│   │   │   ├── desktop
│   │   │   ├── dev
│   │   │   └── devops
│   │   │
│   │   └── default.nix
│   │
│   ├── borba/
│   │   └── default.nix
│   │
│   └── devops/
│       └── default.nix
│
└── hosts/
    ├── dell
    └── macbook
```

---

## 🖥️ Installation

```bash
sudo nixos-rebuild switch --flake .#<HOSTNAME>
```

Example:

```bash
sudo nixos-rebuild switch --flake .#dell
```

---

## 👤 Users & Home Manager

Each user has its own Home Manager configuration:

```text
home/<username>/default.nix
```

Shared modules live under `home/common/`, divided into:

- **core** → essentials (shell, git, terminal, tmux)
- **profiles** → optional toolsets (desktop, dev, devops)

Example user import:

```nix
imports = [
  ../common/core
  ../common/profiles/dev
  ../common/profiles/desktop
];

home.stateVersion = "25.11";
```

---

## 🧰 What’s Installed

### System-wide (NixOS)

- Base utilities
- Fonts
- Users & groups
- Docker (system service)
- Networking and hardware support

### Home Manager

**Core modules**:

- Git
- Zsh + Powerlevel10k
- Alacritty (Catppuccin)
- Tmux

**Profiles**:

- Desktop (Wayland stack, clipboard, screenshots, UX tools)
- Dev (Go, Rust, LSPs, formatters)
- DevOps (Docker tooling, cloud-native utilities)

---

## 🖼️ Wayland Desktop

Includes:

- Waybar
- Rofi
- wl-clipboard + cliphist
- grim / slurp / swappy
- swaylock / swayidle / wlogout
- PipeWire + xdg-desktop-portals (system side)

Designed to work out-of-the-box on a graphical installation.

---

## 🔧 Useful Commands

Build system:

```bash
sudo nixos-rebuild switch --flake .#dell
```

Apply Home Manager:

```bash
home-manager switch --flake .#dell.borba
```

---

## ❤️ Notes

- Modular and reusable structure
- Clear separation between system and user space
- Easy to enable/disable features per user

Enjoy NixOS 🚀
