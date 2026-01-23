[![NixOS CI](https://github.com/waldirborbajr/nixos-config/actions/workflows/nixos.yaml/badge.svg)](https://github.com/waldirborbajr/nixos-config/actions/workflows/nixos.yaml)

# BORBA JR W – NixOS Configuration ❄️

# 🧊 nixos-config

Declarative, modular **multi-host NixOS configuration**, focused on performance, clarity, and on-demand features.

This repository is the **single source of truth** for my personal Linux infrastructure, supporting machines with very different capabilities while keeping one consistent workflow.

---

## 🎯 Project Goals

- One repository, multiple hosts
- Clear separation between:
  - Core system
  - Hardware
  - Desktop environments
  - Optional features
- Avoid unnecessary heavy rebuilds
- Containers, Kubernetes and virtualization **only when explicitly enabled**
- Predictable performance, even on old hardware

---

## 🖥️ Supported Hardware

### 🍎 MacBook Pro 13" (2011)
- Architecture: x86_64
- RAM: 16 GB
- Storage: 500 GB SSD
- Role: main workstation
- Desktop: Hyprland (Wayland) + GNOME (via GDM)
- Optional features: DEVOPS / QEMU (on-demand)

### 💻 Dell Inspiron 1456
- Architecture: x86_64
- RAM: 4 GB
- Storage: 120 GB SSD
- Role: basic usage / study machine
- Desktop: i3 (X11)
- Optional features: all disabled (Docker, K3s, QEMU)

---

## 🧱 Repository Architecture

```
.
├── ARCHITECTURE.md
├── CHANGELOG.md
├── IINSTALL.md
├── LICENSE
├── Makefile
├── NEWHOST.md
├── OPERATIONS.md
├── README.md
├── VERSIONING.md
├── build.sh
├── core.nix
├── default.nix
├── dump.sh
├── flake.lock
├── flake.nix
├── hardware-configuration-dell.nix
├── hardware-configuration-macbook.nix
├── hosts
│ ├── dell.nix
│ └── macbook.nix
├── init.sh
├── link.sh
├── modules
│ ├── audio.nix
│ ├── autologin.nix
│ ├── base.nix
│ ├── containers
│ │ ├── common.nix
│ │ ├── docker.nix
│ │ ├── k3s.nix
│ │ └── podman.nix
│ ├── desktops
│ │ ├── gnome.nix
│ │ └── hyprland
│ │ ├── default.nix
│ │ ├── hyprland.conf
│ │ ├── waybar-config.json
│ │ └── waybar-style.css
│ ├── features
│ │ ├── devops.nix
│ │ └── qemu.nix
│ ├── flatpak
│ │ ├── enable.nix
│ │ └── packages.nix
│ ├── fonts.nix
│ ├── hardware
│ │ ├── dell.nix
│ │ └── macbook.nix
│ ├── networking.nix
│ ├── nixpkgs.nix
│ ├── nodejs
│ │ ├── common.nix
│ │ ├── default.nix
│ │ └── enable.nix
│ ├── performance
│ │ ├── common.nix
│ │ ├── dell.nix
│ │ └── macbook.nix
│ ├── python
│ │ ├── common.nix
│ │ ├── default.nix
│ │ ├── poetry.nix
│ │ └── uv.nix
│ ├── ssh.nix
│ ├── system-packages.nix
│ ├── users
│ │ └── borba.nix
│ └── virtualization
│ └── libvirt.nix
├── profiles
│ ├── dell.nix
│ └── macbook.nix
├── scripts
│ ├── ci-build.sh
│ ├── ci-checks.sh
│ ├── ci-eval.sh
│ └── flatpak-sync.sh
└── troubleshoot.sh
```

---

## 🧩 Feature Flags (On-Demand)

Heavy components are **disabled by default**.

### DEVOPS
- Docker
- K3s
- DevOps tooling

### QEMU
- libvirtd
- QEMU
- virt-manager

Flags are **independent** and can be combined freely.

---

## 🧪 Usage (Makefile)

```
make switch HOST=macbook  
DEVOPS=1 make switch HOST=macbook  
QEMU=1 make switch HOST=macbook  
DEVOPS=1 QEMU=1 make switch HOST=macbook  
```

Dell (always minimal):

```
make switch HOST=dell
```

Run:

```
make help
```

---

## ⚡ Performance Strategy

- schedutil CPU governor (MacBook)
- ZRAM enabled
- systemd startup optimizations
- journald size limits
- heavy services disabled by default
- Dell treated as low-resource machine

Troubleshooting:

```
./troubleshoot.sh
```

---

## ➕ Adding a New Host

See:
NEWHOST.md

---

## 📜 License

MIT

---

## 👤 Author

BORBA JR W

Declarative infrastructure. Pragmatic design. Zero waste.
