# Borba NixOS Config — Conventions for LLMs

## Repository

Flake multi-host NixOS + Home Manager config for 4 physical/VM hosts plus
one standalone macOS home-manager profile:

- `configuration.nix` — thin index, imports topic modules from `modules/`.
- `modules/` — system-level modules split by topic (system-base, fonts,
  users-and-home, desktop-niri, audio, hardware-quirks, packages, ssh, sops,
  containers-docker, containers-podman, kubernetes-dev).
- `home/` — Home Manager config. `home/default.nix` is a thin index importing
  `home/` (identity, shell, editors, cli-and-terminal, desktop,
  helix/). Dotfile contents live in `home/configs/` inside the flake — no
  external dependency on a separate dotfiles repo.
- `hosts/<hostname>/` — per-host `default.nix` + `hardware-configuration.nix`.
  `modules/mac_workstation.nix` / `modules/mac_vm.nix` hold config shared only by the Mac family
  (`broadcom-wifi.nix`, `mac-workstation.nix`, `mac-vm-workstation.nix`).
  `home/macbook.nix` is the odd one out: standalone home-manager only,
  no NixOS module, no `hardware-configuration.nix`.
- `devshells/` — per-language dev shells (arduino, go, latex, lua, mariadb,
  mongodb, postgresql, python, rust, sqlite), each its own `flake.nix`.
- `treefmt.nix` — formatter config (alejandra + deadnix + statix), wired
  into the flake's `formatter` and `checks.format` outputs.
- `.sops.yaml` / `hosts/<hostname>/secrets/<hostname>.yaml` — per-host
  encrypted secrets, one age key per host, no shared secrets file.
- `scripts/nixos-manager.sh` — the deploy/rebuild wrapper (see "Building and
  Deploying" below); replaces raw `nixos-rebuild`/`home-manager` calls for
  day-to-day use.

## Flake attrs vs. real hostnames

The flake attr in `nixosConfigurations`/`homeConfigurations` is **not**
always the same as the machine's real hostname. Source of truth is
`flake.nix`; `scripts/nixos-manager.sh` reads it at runtime (`nix eval` + `jq`)
rather than hardcoding it.

| flake attr | real hostname | arch | role |
|------------|----------------|------------------|--------------------------------|
| `dell` | `dell1564` | x86_64-linux | Dell Inspiron 1564 (weakest box) |
| `mac2011` | `mac2011` | x86_64-linux | MacBook Pro 13" (2011), main workstation |
| `m2utm` | `macutm` | aarch64-linux | Apple Silicon VM (UTM) |
| `macvmf` | `macvmf` | aarch64-linux | Apple Silicon VM (VMware Fusion) |
| `borba@macbook` (homeConfigurations, not nixosConfigurations) | — | aarch64-darwin | MacBook M2 físico, home-manager standalone only |

`dell1456` is a legacy/pre-rename alias for `dell1564` — kept in
`scripts/nixos-manager.sh`'s `HOST_ALIAS_TO_ATTR`, not a typo to "fix".

## Commit Messages

No strict convention enforced yet in this repo (unlike Foundry's
`type(scope):` format) — keep messages short, imperative, and scoped to
what actually changed (e.g. `helix: add onenord theme`, `cli: enable nh`).
If a stricter convention is wanted later, mirror Foundry's
`type(scope): description` (types: `feat`, `fix`, `refactor`, `chore`).

## Directory Structure

```
.
├── global_constants.nix       # { username = "borba"; }
├── features.nix                # PAINEL: liga/desliga pacotes por host
├── configuration.nix           # thin index -> modules/
├── modules/                    # system-level modules, flat, snake_case
│   ├── base_system.nix
│   ├── fonts.nix
│   ├── user_borba.nix
│   ├── desktop_niri.nix
│   ├── audio.nix
│   ├── hardware_quirks.nix
│   ├── root_pkgs.nix
│   ├── ssh.nix
│   ├── sops.nix
│   ├── containers.nix
│   ├── containers_docker.nix
│   ├── containers_podman.nix
│   ├── containers_kubernetes.nix
│   ├── mac_workstation.nix     # shared ONLY by the Mac family
│   ├── mac_vm.nix              # layer on top of mac_workstation.nix, for macutm/macvmf
│   ├── broadcom_wifi.nix       # shared by dell1564 + mac2011
│   └── dev/
│       ├── default.nix
│       ├── base.nix
│       └── {go,rust,python,lua,nix,...}.nix
├── home/
│   ├── home.nix                # base profile: identity/shell/editors/cli-and-terminal
│   ├── home_niri.nix           # desktop layer (niri/waybar/emacs-vanilla), on top of home.nix
│   ├── identity.nix
│   ├── shell.nix
│   ├── editors.nix
│   ├── cli-and-terminal.nix
│   ├── desktop.nix
│   ├── emacs-vanilla.nix
│   ├── helix/
│   │   ├── default.nix
│   │   └── theme.nix           # onenord — ported from Foundry's helix/theme.nix
│   ├── dell1564.nix            # thin: imports ./home_niri.nix
│   ├── mac2011.nix
│   ├── macutm.nix
│   ├── macvmf.nix
│   ├── macbook.nix             # standalone home-manager entry point (no nix-darwin)
│   └── configs/                # raw dotfile contents (zsh, tmux, wezterm, etc.) — SOURCE OF TRUTH
├── hosts/
│   ├── dell1564/
│   │   ├── configuration.nix   # hardware + host overrides + wires home/dell1564.nix
│   │   └── hardware-configuration.nix
│   ├── mac2011/
│   ├── macutm/
│   └── macvmf/
├── devshells/
│   └── {lang}/flake.nix
├── scripts/
│   ├── nixos-manager.sh        # deploy/rebuild wrapper (see below)
│   ├── tmux-devshell.sh
│   ├── zellij-devshell.sh
│   ├── chmox.sh
│   └── logitech-k380-bluetooth-linux-fix/
├── flake.nix
├── treefmt.nix
└── .sops.yaml
```

## Code Style

- **Formatter**: `nix fmt` (Alejandra via treefmt-nix, plus deadnix + statix
  lint checks). ALWAYS format after edits. Never format unmodified files.
- **Indentation**: 2 spaces, no tabs.
- **Line endings**: LF, final newline, trimmed trailing whitespace.
- **Nix conventions**:
  - Top-level modules are functions taking `{pkgs, lib, config, ...}` (or a
    subset — only destructure what's actually used).
  - `specialArgs`/`extraSpecialArgs` carry `inputs`, `hostname`, and
    `pkgs-unstable` (see `flake.nix` `mkHost`/`mkMacHome`) — available to
    any NixOS or home-manager module without re-importing.
  - Feature modules that need conditional inclusion should use a boolean
    `enable`-style option; most current modules are unconditionally
    imported (no feature-flag pattern in place yet, unlike Foundry).
  - Home-manager dotfile content: prefer `xdg.configFile.<name> = { source = "${configs}/<name>"; recursive = true; }` pointing at `home/configs/`
    over inline heredocs, so the raw dotfile stays diffable/portable.

## Secrets

- Managed with **sops-nix**, keys defined in `.sops.yaml`.
- **Per-host only** — no shared secrets file (unlike Foundry's
  `hosts/nixos/common/secrets.yaml`). Each host's `secrets/<hostname>.yaml`
  is encrypted only to that host's own age key.
- 3 of 4 hosts (`dell1564`, `macutm`, `macvmf`) still have **placeholder**
  age keys in `.sops.yaml` pending the real values — do not assume they're
  live until confirmed.
- **Never** read secrets into context. Ask the user to do it.

## Building and Deploying

Day-to-day: use **`./scripts/nixos-manager.sh`** (interactive menu or
`./scripts/nixos-manager.sh <option> [host]`), not raw `nixos-rebuild`/
`home-manager` — it handles git branch selection, OOM-safe serial builds
on `dell` (`--max-jobs 1 --cores 1`), generation-change verification, and
bootloader sync after cleanup. Key options: `flake` (build+switch),
`dry` (test build, no activation), `update` (flake.lock bump + rebuild),
`clean` (GC), `rollback`, `check` (`nix flake check`), `m`/`c` for the
`macbook` home-manager-only host.

`nh` (see `home/cli-and-terminal.nix`, `programs.nh`) is also
available as a lighter-weight alternative for ad-hoc `nh os switch` /
`nh home switch` / `nh clean all` outside the wrapper's git-flow — its
`flake` is pinned to `$HOME/nixos-config`, the same local clone path
`scripts/nixos-manager.sh` expects.

- Format check: `nix fmt` (or `nix flake check`, which includes it).
- Build a host without activating: `./scripts/nixos-manager.sh dry <flake-attr>`
  or `nixos-rebuild build --flake .#<flake-attr>`.
- Deploy to the current host: `./scripts/nixos-manager.sh flake <flake-attr>` or
  `sudo nixos-rebuild switch --flake .#<flake-attr>`.
- Deploy the macOS-only home-manager profile: `./scripts/nixos-manager.sh m` or
  `home-manager switch --flake .#borba@macbook`.
- No Hydra/CI auto-upgrade in this repo (unlike Foundry) — every deploy is
  manual, via `scripts/nixos-manager.sh` or direct commands.

### Post-deploy verification

`scripts/nixos-manager.sh` already checks `/run/current-system` before/after and
fails loudly on OOM-kill or activation mismatch. For a manual check:

1. `ssh <host> -- readlink -f /run/current-system`
1. Compare against the expected generation shown by
   `./scripts/nixos-manager.sh g` (list generations).

## Nix eval

When verifying config output before deploying:

- NixOS config: `nixosConfigurations.<flake-attr>.config.<path>`
- Home-manager (managed by NixOS): `nixosConfigurations.<flake-attr>.config.home-manager.users.borba.<path>`
- Standalone macbook home-manager: `homeConfigurations."borba@macbook".config.<path>`
- `nix eval .#<output> --json` to inspect raw attribute values.
