# Borba NixOS Config — Conventions for LLMs

## Repository

Flake multi-host NixOS + Home Manager config for 4 physical/VM hosts plus
one standalone macOS home-manager profile:

- `hosts/<hostname>/configuration.nix` — thin-ish per-host entry point:
  hardware quirks + `imports` of shared profiles/modules + wires
  `home-manager.users.borba` to `hosts/<hostname>/home/home.nix`. No
  top-level `configuration.nix` — each host owns its own.
- `system/profiles/` — shared system-level layers, imported by hosts:
  `base.nix` (kernel, ssh, sops, dev.nix, ssh-trust.nix, boot basics —
  every host), `desktop.nix` (GUI layer), `server.nix`,
  `x86/desktop.nix` (x86-only desktop extras). `x86/docker.nix`,
  `x86/podman.nix`, `x86/kubernetes.nix` are imported by `base.nix` and
  turned on per host via `development.containers.<x>.enable` (default
  off; see `hosts/mac2011/configuration.nix`).
- `system/modules/` — single-purpose system modules: `dev.nix`
  (`development.languages.<lang>.enable`, per-host toggle — see
  mac2011 for the pattern), `ssh-trust.nix` (SSH known_hosts +
  authorized_keys between hosts), `mac-family.nix` / `mac-vm.nix`
  (shared only by the Mac family), `broadcom-wifi.nix` (dell1564 +
  mac2011).
- `home/profiles/` — mirrors `system/profiles/`: `base.nix` (shell,
  editors, cli-and-terminal, git, terminal emulators — every host),
  `desktop.nix`, `x86/desktop.nix`.
- `home/modules/` — one file per program (`alacritty.nix`, `wezterm.nix`,
  `tmux.nix`, `zsh.nix`, `git.nix`, `editors.nix`, `helix/`, etc). Some
  are opt-in by import rather than by an `enable` option (e.g. `kitty.nix`
  is not imported and `wezterm.nix` is commented out in
  `home/profiles/desktop.nix`); check profile imports before assuming a
  module is active. `editors.nix` is an example of Home Manager modules
  that expose per-program enable options.
- `home/configs/` — raw config files for programs such as niri, waybar,
  helix, nvim, and zellij. Depending on the owning module, they may be
  linked with `xdg.configFile` or consumed another way; not every active
  program config lives here. Legacy files such as `zsh/.zshrc.old` and
  `emacs/init.el.OLD` are not active configuration.
- `hosts/<hostname>/home/home.nix` — the home-manager entry point for
  that host (imported by `mkHost`/`mkMacHome` in `flake.nix`).
  `hosts/macbook/` is the odd one out: only a `home/` dir, no
  `configuration.nix`, no `hardware-configuration.nix` — standalone
  home-manager, not a NixOS host.
- `devshells/` — per-language dev shells (arduino, ferretdb, go, latex,
  lua, mariadb, mongodb, postgresql, python, rust, sqlite), each its
  own `flake.nix`.
- `treefmt.nix` — formatter config (alejandra + deadnix + statix), wired
  into the flake's `formatter` and `checks.formatting` outputs.
- `.sops.yaml` / `hosts/<hostname>/secrets/<hostname>.yaml` — per-host
  encrypted secrets, one age key per host, no shared secrets file.
- `nixos-manager.sh` — the deploy/rebuild wrapper (see "Building and
  Deploying" below), **at the repo root**, not under `scripts/`;
  replaces raw `nixos-rebuild`/`home-manager` calls for day-to-day use.
  `scripts/` holds smaller one-off helpers (`backup-age-key.sh`,
  `manage-ssh-sops.sh`, `tmux-devshell.sh`, `zellij-devshell.sh`,
  `chmox.sh`, the Logitech K380 fix).

## Flake attrs vs. real hostnames

The flake attr in `nixosConfigurations`/`homeConfigurations` is **not**
always the same as the machine's real hostname. Source of truth is
`flake.nix`; `nixos-manager.sh` reads it at runtime (`nix eval` + `jq`)
rather than hardcoding it.

| flake attr | real hostname | arch | role |
|------------|----------------|------------------|--------------------------------|
| `dell` | `dell1564` | x86_64-linux | Dell Inspiron 1564 (weakest box) |
| `mac2011` | `mac2011` | x86_64-linux | MacBook Pro 13" (2011), main workstation |
| `m2utm` | `macutm` | aarch64-linux | Apple Silicon VM (UTM) |
| `macvmf` | `macvmf` | aarch64-linux | Apple Silicon VM (VMware Fusion) |
| `borba@macbook` (homeConfigurations, not nixosConfigurations) | — | aarch64-darwin | MacBook M2 físico, home-manager standalone only |

`dell1456` is a legacy/pre-rename alias for `dell1564` — kept in
`nixos-manager.sh`'s `HOST_ALIAS_TO_ATTR` (Dell may still report that
old hostname until the first successful rebuild), not a typo to "fix".

## Commit Messages

No strict convention enforced yet in this repo (unlike Foundry's
`type(scope):` format) — keep messages short, imperative, and scoped to
what actually changed (e.g. `helix: add onenord theme`, `cli: enable nh`).
If a stricter convention is wanted later, mirror Foundry's
`type(scope): description` (types: `feat`, `fix`, `refactor`, `chore`).

## Directory Structure

```
.
├── flake.nix                   # mkHost/mkMacHome, nixosConfigurations, homeConfigurations
├── nixos-manager.sh            # deploy/rebuild wrapper (see below) — repo ROOT, not scripts/
├── treefmt.nix
├── .sops.yaml
├── wallpapers/                 # global pool, same images for every host — linked by
│                                # home/modules/desktop.nix into ~/.local/share/wallpapers;
│                                # login.jpg is the regreet (login screen) background, excluded
│                                # from the random pick; random-wallpaper script picks the rest
├── system/
│   ├── overlays.nix            # rust-overlay wiring (pkgs.rust-bin)
│   ├── profiles/
│   │   ├── base.nix            # every host: kernel, ssh, sops, imports dev.nix + ssh-trust.nix
│   │   ├── desktop.nix         # GUI layer
│   │   ├── server.nix
│   │   └── x86/
│   │       ├── desktop.nix     # x86-only desktop extras
│   │       ├── docker.nix      # development.containers.docker.enable
│   │       ├── podman.nix      # development.containers.podman.enable
│   │       └── kubernetes.nix  # development.containers.kubernetes.enable (needs docker or podman)
│   └── modules/
│       ├── dev.nix             # development.languages.<lang>.enable, per host
│       ├── ssh-trust.nix       # cross-host known_hosts + authorizedKeys
│       ├── mac-family.nix      # shared ONLY by the Mac family
│       ├── mac-vm.nix          # layer on top of mac-family.nix, for macutm/macvmf
│       └── broadcom-wifi.nix   # shared by dell1564 + mac2011
├── home/
│   ├── profiles/
│   │   ├── base.nix            # every host: shell, editors, cli-and-terminal, git, terminal
│   │   ├── desktop.nix
│   │   └── x86/desktop.nix
│   ├── modules/                # one file per program (see "Home Manager" note below)
│   │   ├── alacritty.nix       # active default terminal
│   │   ├── wezterm.nix         # written, NOT imported — opt-in
│   │   ├── kitty.nix           # written, NOT imported — opt-in
│   │   ├── editors.nix         # helix/neovim/emacs enable toggles + $EDITOR precedence
│   │   ├── helix/
│   │   └── {zsh,tmux,git,lazygit,atuin,btop,...}.nix
│   ├── pkgs/
│   └── configs/                # raw dotfile contents — SOURCE OF TRUTH, linked via xdg.configFile
│       ├── wezterm/, niri/, waybar/, helix/, nvim/, zellij/
│       └── *.old/              # leftovers from a past migration, not wired into any module
├── hosts/
│   ├── dell1564/
│   │   ├── configuration.nix   # hardware + host overrides + imports of system/profiles
│   │   ├── hardware-configuration.nix
│   │   ├── boot.nix
│   │   ├── home/home.nix       # this host's home-manager entry point
│   │   ├── pkgs/, scripts/, services/, secrets/
│   ├── mac2011/                # same shape as dell1564
│   ├── macutm/                 # same shape, no boot.nix
│   ├── macvmf/                 # same shape, no boot.nix
│   └── macbook/
│       └── home/home.nix       # standalone home-manager only — no configuration.nix, no hardware-configuration.nix
├── devshells/
│   └── {arduino,ferretdb,go,latex,lua,mariadb,mongodb,postgresql,python,rust,sqlite}/flake.nix
└── scripts/                    # smaller one-off helpers, NOT the deploy wrapper
    ├── backup-age-key.sh
    ├── manage-ssh-sops.sh
    ├── tmux-devshell.sh
    ├── zellij-devshell.sh
    ├── chmox.sh
    └── logitech-k380-bluetooth-linux-fix/
```

### `system/` opt-in pattern (`enable` flags)

`system/profiles/x86/{docker,podman,kubernetes}.nix` declare real options
(`development.containers.<x>.enable`, default `false`), the same pattern
as `system/modules/dev.nix` (`development.languages.<lang>.enable`). They
are imported once by `system/profiles/base.nix`, so every host has the
options; each host turns on what it needs in its `configuration.nix`.
Do **not** comment/uncomment imports to activate these — flip the flag.

`home/modules/wezterm.nix` and `home/modules/kitty.nix` are written but
not imported by any `home/profiles/*.nix` — same opt-in idea, at the
home-manager level. Alacritty is the only terminal actually wired in.

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
  - Use a boolean `enable` option for reusable optional features that
    genuinely vary by host or need to be independently toggled. Keep
    always-on shared configuration directly in its profile; do not add
    an option to every module just for uniformity. Existing examples
    include `development.languages.*`, `development.containers.*`,
    `power.alwaysOn.enable`, and `editors.*.enable`.
  - For Home Manager configuration, follow the owning module's existing
    pattern. Use `xdg.configFile` to link raw files from `home/configs/`
    when that is how the program is managed; native `programs.*` settings
    and inline configuration are also used. In particular,
    `home/modules/wezterm.nix` intentionally keeps its Lua config inline;
    do not convert it to a linked file without checking first.

## Secrets

- Managed with **sops-nix**, keys defined in `.sops.yaml`.
- **Per-host only** — no shared secrets file (unlike Foundry's
  `hosts/nixos/common/secrets.yaml`). Each host's `secrets/<hostname>.yaml`
  is encrypted only to that host's own age key.
- All 4 NixOS hosts (`dell1564`, `mac2011`, `macutm`, `macvmf`) have real
  age keys in `.sops.yaml` — not placeholders.
- **Never** read secrets into context. Ask the user to do it.

## Building and Deploying

Day-to-day: use **`./nixos-manager.sh`** (interactive menu or
`./nixos-manager.sh <option> [host]`), not raw `nixos-rebuild`/
`home-manager` — it handles git branch selection, OOM-safe serial builds
on `dell` (`--max-jobs 1 --cores 1`), generation-change verification, and
bootloader sync after cleanup. Key options: `flake` (build+switch),
`dry` (test build, no activation), `update` (flake.lock bump + rebuild),
`clean` (GC), `rollback`, `check` (`nix flake check`), `m`/`c` for the
`macbook` home-manager-only host.

`nh` (see `home/modules/cli-and-terminal.nix`, `programs.nh`) is also
available as a lighter-weight alternative for ad-hoc `nh os switch` /
`nh home switch` / `nh clean all` outside the wrapper's git-flow — its
`flake` is pinned to `$HOME/nixos-config`, the same local clone path
`nixos-manager.sh` expects.

For code-editing tasks, do not run a deploy, `switch`, rollback, or other
operation that changes a host unless the user explicitly asks. Prefer a
format check, flake evaluation, or build-only validation when available.

- Format check: `nix fmt` (or `nix flake check`, which includes it).
- Build a host without activating: `./nixos-manager.sh dry <flake-attr>`
  or `nixos-rebuild build --flake .#<flake-attr>`.
- Deploy to the current host: `./nixos-manager.sh flake <flake-attr>` or
  `sudo nixos-rebuild switch --flake .#<flake-attr>`.
- Deploy the macOS-only home-manager profile: `./nixos-manager.sh m` or
  `home-manager switch --flake .#borba@macbook`.
- No Hydra/CI auto-upgrade in this repo (unlike Foundry) — every deploy is
  manual, via `nixos-manager.sh` or direct commands.

### Post-deploy verification

`nixos-manager.sh` already checks `/run/current-system` before/after and
fails loudly on OOM-kill or activation mismatch. For a manual check:

1. `ssh <host> -- readlink -f /run/current-system`
1. Compare against the expected generation shown by
   `./nixos-manager.sh g` (list generations).

## Nix eval

When verifying config output before deploying:

- NixOS config: `nixosConfigurations.<flake-attr>.config.<path>`
- Home-manager (managed by NixOS): `nixosConfigurations.<flake-attr>.config.home-manager.users.borba.<path>`
- Standalone macbook home-manager: `homeConfigurations."borba@macbook".config.<path>`
- `nix eval .#<output> --json` to inspect raw attribute values.
