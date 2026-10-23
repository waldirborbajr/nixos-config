<p align="center">
<img alt="NixOS" src="https://raw.githubusercontent.com/NixOS/nixos-artwork/9d2cdedd73d64a068214482902adea3d02783ba8/logo/nix-snowflake-rainbow.svg" width="140px"/>
</p>
<h1 align="center">
NixOS - BORBA JR, W - Configuration
</h1>

[![Nix](https://github.com/waldirborbajr/nixos-config/actions/workflows/nix.yaml/badge.svg)](https://github.com/waldirborbajr/nixos-config/actions/workflows/nix.yaml)

A multi-host flake (`flake.nix` → each host's
`hosts/<host>/configuration.nix`, importing shared profiles/modules from
`system/profiles/` and `system/modules/` — there is no single root
`configuration.nix` —, with modules such as
`system/modules/mac-family.nix` shared by the Mac family). [Home
Manager](https://github.com/nix-community/home-manager) manages the user
environment (`hosts/<host>/home/home.nix` + `home/profiles/` +
`home/modules/` + `home/configs/`), while
[sops-nix](https://github.com/Mic92/sops-nix) manages per-host secrets.
See [`docs/architecture.md`](docs/architecture.md) for a conceptual
overview of the layers. [`docs/DENDRITIC-PATTERN.md`](docs/DENDRITIC-PATTERN.md)
is an aspirational reference, not a literal description of the current tree.

## 🖥️ Supported Hardware

> ⚠️ Current desktop stack (all 4 hosts): **niri** (Wayland
> scrollable-tiling compositor) + **waybar** + **greetd + regreet**
> (`cage` + `regreet`, Catppuccin Mocha theme) as the greeter/display
> manager. No host uses i3/X11, GNOME/GDM, or `ly`; all use the stack
> above (see `system/profiles/desktop.nix`; host files import this profile
> and add hardware-specific settings).

### 🍎 MacBook Pro 13" (2011) — `mac2011`

- Architecture: x86_64
- RAM: 16 GB
- Storage: 500 GB SSD
- Role: main workstation (physical hardware)
- Desktop: niri + waybar (Wayland, via greetd/regreet)
- Wi-Fi: Broadcom BCM4331, open-source `b43` driver (the proprietary
  `broadcom-sta` driver is disabled because it fails to build against
  kernel ≥ 7.1)
- Bluetooth: `hardware.bluetooth.settings.General.ControllerMode` is
  forced to `"bredr"` (`lib.mkForce`) — the built-in Broadcom controller
  supports classic BR/EDR only, not true LE; the NixOS module's default
  (`"dual"`) does not match the hardware
- Tailscale: the only host configured as a server; advertises the
  `192.168.0.0/24` LAN route and acts as an exit node
- Host-specific extras: `spotify`, `chirp` (radio programming software),
  and wireless debugging tools (`iw`, `wirelesstools`), which are not
  available or applicable to the aarch64 VMs
- Launcher: [Vicinae](https://github.com/vicinaehq/vicinae) (Raycast-like)

### 💻 Dell Inspiron 1564 — `dell1564`

- Architecture: x86_64
- RAM: 4 GB
- Storage: 120 GB SSD
- Role: basic use / study machine
- Desktop: niri + waybar (Wayland, via greetd/regreet)
- Boot: legacy BIOS + GRUB (`/dev/sda`); the other hosts use
  `systemd-boot`/EFI
- Keyboard: ABNT2 (`br-abnt2`)
- Wi-Fi: Broadcom BCM4312 (LP-PHY), open-source `b43` driver + firmware
  pinned to `b43Firmware_6_30_163_46` (a version specifically for LP-PHY
  chips; the proprietary `wl` driver was tested and abandoned because it
  is incompatible with recent kernels)
- No Vicinae, containers, or heavyweight packages — this is the least
  powerful machine in the fleet
- Note: the machine's legacy hostname was `dell1456`; the flake uses
  `dell1564` (see the aliases in `nixos-manager.sh` and
  `manage-ssh-sops.sh`). Verify the machine's actual model name before
  treating either hostname as a typo.

### 🍏 Apple Silicon VM (UTM) — `macutm`

- Architecture: aarch64
- Role: workstation in a VM (UTM)
- Desktop: niri + waybar (Wayland, via greetd/regreet — software
  rendering forced with `WLR_RENDERER=pixman` and `GSK_RENDERER=cairo`);
  shares its base with `macvmf` in `system/modules/mac-vm.nix`
- Containers: none by default — Docker/Podman/Kubernetes are opt-in here,
  as on every other host (see "Containers / Kubernetes" below); currently
  only `mac2011` enables Docker (`development.containers.docker.enable`)
- `boot.kernelParams = [ "mitigations=off" ]` — VM performance improvement

### 🍏 Apple Silicon VM (VMware Fusion) — `macvmf`

- Architecture: aarch64
- Role: workstation in a VM (VMware Fusion), with the guest agent
  `virtualisation.vmware.guest.enable`
- Desktop: niri + waybar (Wayland, via greetd/regreet), sharing the same
  base as `macutm` (`system/modules/mac-vm.nix`)
- Containers: opt-in; see the `macutm` note above

### 🍏 MacBook M2 (physical) — `macbook` (standalone Home Manager)

- Architecture: aarch64-darwin
- Role: daily app installation — **not** a `nixosConfiguration`, but a
  `homeConfigurations."borba@macbook"` entry (standalone Home Manager,
  through `mkMacHome` in `flake.nix`)
- No nix-darwin, niri, waybar, or greetd — no system or desktop
  management; `home-manager switch` manages user packages and dotfiles
- Imports only `home/profiles/base.nix` (shell, editors, zellij, tmux, nh,
  tuios, git, terminal emulators) — **not** `home/profiles/desktop.nix`, which
  is for niri/Wayland and does not apply to macOS
- Host-specific `home.packages` (`hosts/macbook/home/home.nix`): currently
  only `darktable` — editors (`neovim`/`helix`/`emacs`, toggled in
  `home/modules/editors.nix`) come from the shared
  `home/profiles/base.nix` and do not need to be repeated here
- `home.homeDirectory` is overridden to `/Users/borba` via `lib.mkForce`,
  since identity modules assume `/home/borba` (Linux) by default
- `backupFileExtension = "hm-backup"` comes from the shared
  `system/profiles/base.nix` — a pre-existing dotfile not managed by Nix
  is renamed to `<file>.hm-backup` instead of being overwritten without
  a backup, starting with the first activation
- **Packages from the VMs (`macutm`/`macvmf`) or `system/*` modules do not
  reach this host** — these are entirely separate `nixosConfigurations`;
  only settings from `home/profiles/base.nix`, `home/modules/`, or
  `hosts/macbook/home/home.nix` are shared with this host
- Usage: `./nixos-manager.sh macbook` (or menu option `m`) — see the
  `nixos-manager.sh` section below

### Shared Mac family base (`system/modules/mac-family.nix`)

Programs, keyboard (`us` + `mac` variant), and browser (Firefox Developer
Edition) shared by `mac2011`, `macutm`, and `macvmf` live in one common
module instead of being duplicated. `dell1564` does **not** import this
module; it has a smaller package set and stable Firefox.
`system/modules/mac-vm.nix` adds a layer on top of this module for
`macutm`/`macvmf` (the two Apple Silicon VMs).

______________________________________________________________________

## 🎛️ Enabling and disabling packages per host

There is no central control panel — each
`hosts/<host>/configuration.nix` is where host-specific settings belong.
Two patterns are used:

**Boolean toggle** — `system/modules/dev.nix` exposes
`development.languages.<lang>.enable` (go, rust, sqlite, nix, python,
lua, arduino, latex, postgresql, mariadb, mongodb, ferretdb). The module
is already imported by `system/profiles/base.nix` on every host; only the
`enable` values vary by host, set in that host's `configuration.nix`:

```nix
development.languages = {
  go.enable = true;
  rust.enable = true;
  sqlite.enable = true;
  # all others = false
};
```

**`enable` flags (containers)** —
`system/profiles/x86/{docker,podman,kubernetes}.nix` declare
`development.containers.<x>.enable` (default `false`), following the same
pattern as `dev.nix`. To enable one on a host, change its flag in that
host's `configuration.nix` (see "Containers / Kubernetes" below).
Home Manager's `home/modules/editors.nix` also exposes `enable` options
for editors. Alternative terminals are opt-in by import: `wezterm.nix` is
inactive (its import is commented out in `home/profiles/desktop.nix`) and
`kitty.nix` is not imported. Alacritty is the configured terminal.

There is no `features.nix` or `global_constants.nix` in this repository —
`username = "borba"` is defined directly in `flake.nix` (`outputs`) and
passed through `specialArgs`/`extraSpecialArgs`.

______________________________________________________________________

## 🧩 Shared profiles (`system/profiles/`, `system/modules/`)

Each `hosts/<host>/configuration.nix` imports a subset of shared profiles
and modules instead of using one root `configuration.nix` for all hosts:

| File | Contents |
|---|---|
| `system/profiles/base.nix` | Kernel, tmpfiles (SSH directory), SSH, SOPS, `development.languages.*` (via `dev.nix`), inter-host SSH trust — imported by **all** hosts |
| `system/profiles/desktop.nix` | Desktop (GUI) layer |
| `system/profiles/server.nix` | Server layer |
| `system/profiles/x86/desktop.nix` | x86_64-only desktop extras |
| `system/modules/dev.nix` | Per-host `development.languages.<lang>.enable` options |
| `system/modules/ssh-trust.nix` | Fleet-wide `authorizedKeys`/`knownHosts` |
| `system/modules/mac-family.nix` | Keyboard, Firefox Developer Edition, packages — Mac family only |
| `system/modules/mac-vm.nix` | Layer on top of `mac-family.nix`, for `macutm`/`macvmf` only |
| `system/modules/broadcom-wifi.nix` | Broadcom Wi-Fi firmware — `dell1564` + `mac2011` |
| `system/profiles/x86/docker.nix` ⚠️ opt-in | Docker Engine (`enableOnBoot = false`, socket-activated) + `docker` group + `docker-compose`/`lazydocker` — `development.containers.docker.enable` flag; see "Containers / Kubernetes" below |
| `system/profiles/x86/podman.nix` ⚠️ opt-in | Rootless Podman + `dockerCompat` (provides the `docker` command when Docker Engine is disabled) + `podman-compose` + weekly auto-update timer — `development.containers.podman.enable` flag |
| `system/profiles/x86/kubernetes.nix` ⚠️ opt-in | `k3d` + `kubectl` + `k9s` (lightweight local cluster, no systemd) — `development.containers.kubernetes.enable` flag; requires Docker or Podman on the same host (assertion) |

To change something, go directly to the file for that topic — there is no
monolithic `configuration.nix` to navigate.

______________________________________________________________________

## 🐳 Containers / Kubernetes (opt-in, disabled by default)

Docker, Podman, and local Kubernetes are only used for specific projects,
not day to day — so the three modules exist in the repository but remain
**disabled** (`enable = false`). Currently only
`hosts/mac2011/configuration.nix` enables Docker. To use them:

```nix
# hosts/<host>/configuration.nix
development.containers = {
  docker.enable = true;
  podman.enable = false;
  kubernetes.enable = false; # requires Docker or Podman to be enabled
};
```

Then run the usual rebuild (`./nixos-manager.sh flake` or `build`). When
you no longer need a feature, set it to `false` and rebuild — none of the
three leaves a service running while disabled.

| Module | What it provides | Footprint when enabled but unused |
|---|---|---|
| `x86/docker.nix` (`development.containers.docker`) | Docker Engine + `docker-compose`/`lazydocker` | Zero until used — with `enableOnBoot = false`, the daemon starts when its socket is accessed (`docker ps`, etc.); after starting, it keeps running until `systemctl stop docker` or reboot |
| `x86/podman.nix` (`development.containers.podman`) | Rootless Podman + `dockerCompat` (the `docker` alias, only when `development.containers.docker` is disabled) + `podman-compose` + weekly auto-update timer | Always zero — no daemon, one process per command; the timer only touches containers labeled `io.containers.autoupdate = "registry"` |
| `x86/kubernetes.nix` (`development.containers.kubernetes`) | `k3d` + `kubectl` + `k9s` | Zero — binaries only, no systemd service; the cluster exists only between `k3d cluster create` and `k3d cluster delete` |

> **`k9s` does not start a cluster by itself** — it is only a dashboard/TUI
> for an existing cluster (through kubeconfig), local or remote. To create
> a local cluster, `x86/kubernetes.nix` also includes `k3d`, which creates
> an ephemeral k3s cluster running in containers on top of the runtime you
> enabled (`x86/docker.nix` or `x86/podman.nix` — one is required to create
> the cluster nodes).
>
> `x86/docker.nix` and `x86/podman.nix` are independent: you can enable
> either one or both. If both are enabled, Podman's `dockerCompat` turns
> itself off to avoid conflicting with Docker Engine's `docker` binary.

______________________________________________________________________

## 🚀 Recreating a host from scratch (order matters)

This section is for anyone (including future-you) who clones this repo onto
a brand-new machine and needs to know **exactly** what to run, and in what
order. Skipping a step or running them out of order is the most common
cause of a failed first `nixos-rebuild switch`.

### Why the order matters

This flake uses [SOPS](https://github.com/getsops/sops) (via
[sops-nix](https://github.com/Mic92/sops-nix)) to encrypt SSH keys
(`hosts/<host>/secrets/<host>.yaml`). `nixos-rebuild switch` decrypts that
file during activation using a local [age](https://github.com/FiloSottile/age)
key at `~/.config/sops/age/keys.txt` (`sops.age.keyFile` in
`system/profiles/base.nix`, imported by every host — per-user, not
`/etc`) — but on a **genuinely fresh**
machine, neither that age key nor the encrypted secrets file exist yet, and
the tools needed to create them (`sops`, `age`, `jq`) only get installed
*by* a successful rebuild. That's a chicken-and-egg problem, and it's
exactly what breaks if you jump straight to step 4 below.

> ⚠️ `~/.config/sops/age/keys.txt` is the **only** thing that can decrypt
> that host's secrets — it's intentionally never committed (see
> `.gitignore`). If the disk is wiped without a backup of this file, every
> secret encrypted for that host becomes permanently unrecoverable, even
> though the encrypted `.yaml` survives fine in git. Back it up with
> `./scripts/backup-age-key.sh` (prints the key + its public fingerprint,
> never writes to disk or network) right after step 3 below, and store it
> in a password manager.

The steps must run in this order:

**1. Install base NixOS** (via the official ISO / installer), with flakes
enabled. At this point you just need a working system with `git`,
`openssh`, and internet access — the full flake config isn't applied yet.

**2. Clone this repo** to the fixed path every host expects:

```bash
git clone git@github.com:waldirborbajr/nixos-config.git ~/nixos-config
```

(If you don't have an SSH key registered with GitHub yet on this fresh
machine, clone via HTTPS first — `https://github.com/waldirborbajr/nixos-config.git`
— you can switch the remote to SSH later once your GitHub key exists,
which happens in step 3.)

**3. Bootstrap SSH keys + SOPS secrets — BEFORE the first real rebuild.**
The tools this needs (`sops`, `age-keygen`, `jq`, `ssh-keygen`) aren't
installed by the system yet, so run them from a temporary ad-hoc shell:

```bash
cd ~/nixos-config
nix shell nixpkgs#sops nixpkgs#age nixpkgs#jq nixpkgs#openssh
./scripts/manage-ssh-sops.sh <host> --clean
```

Replace `<host>` with one of: `dell1564`, `mac2011`, `macutm` (aliases
like `dell`, `mac`, `m2utm` also work — see the script header).

Always use `--clean` the **first** time you set up a host — it builds a
correct, complete encrypted YAML from scratch. Without `--clean`, the
script does incremental `sops set` updates on an existing file, which
assumes the file is already in a valid state.

This step generates and encrypts:

- `borba_ssh_infra_private_key` / `_public_key` — SSH identity for
  server-to-server access
- `borba_ssh_github_private_key` / `_public_key` — SSH identity for
  GitHub/GitLab/Forgejo
- `ssh_host_ed25519_key` — this machine's own SSH host key

Commit and push the resulting `hosts/<host>/secrets/<host>.yaml` (it's
encrypted — safe to commit, contains no plaintext):

```bash
git add hosts/<host>/secrets/<host>.yaml
git commit -m "secrets: bootstrap <host>"
git push origin main
```

**4. Point `/etc/nixos` at the repo and run the real rebuild:**

```bash
./nixos-manager.sh setup      # symlinks /etc/nixos -> ~/nixos-config
./nixos-manager.sh flake      # select branch + host, then rebuild
```

Note: `nixos-manager.sh`, `tmux-devshell.sh` and `zellij-devshell.sh`
live at the **repo root**, not under `scripts/` — only
`manage-ssh-sops.sh` and `backup-age-key.sh` live in `scripts/`. The two
devshell launchers are also installed as commands
(`tmux-devshell`/`zellij-devshell` in `~/.local/bin`, see the section
below) so they work from inside any project, not just the repo root.

This is the first rebuild that can actually succeed, because the age key
and encrypted secrets from step 3 already exist on disk. From here on,
`sops`/`age`/`jq` are installed system-wide and Home Manager manages the
user environment through the modules in `home/modules/`, composed by
`home/profiles/base.nix` and `home/profiles/desktop.nix`. Program settings
may use native `programs.*` options, inline configuration, or selected
files from `home/configs/` linked with `xdg.configFile`. No external
`~/dotfiles` repo or manual `stow` is needed.

**5. Back up the age key** (do this once, right after step 3):

```bash
./scripts/backup-age-key.sh
```

Prints the key and its public fingerprint so you can paste it into a
password manager. Never commit this output anywhere.

**6. Re-running the SSH/SOPS script later** (e.g. adding a new key,
rotating an existing one) uses the same script *without* `--clean`:

```bash
./scripts/manage-ssh-sops.sh <host>
```

This updates individual keys via `sops set`, preserving any other
secret already present in the file — safe to re-run anytime.

### Quick reference

| Step | Command | Requires |
|---|---|---|
| 1 | Install base NixOS | — |
| 2 | `git clone ... ~/nixos-config` | git |
| 3 | `nix shell nixpkgs#sops nixpkgs#age nixpkgs#jq nixpkgs#openssh` then `./scripts/manage-ssh-sops.sh <host> --clean` | ad-hoc `nix shell` |
| 3b | `git add/commit/push` the encrypted secrets file | git |
| 4 | `./nixos-manager.sh setup` then `flake` | steps 1–3 done |
| 5 | `./scripts/backup-age-key.sh` — save output in a password manager | age key exists (step 3) |
| 6+ | `./scripts/manage-ssh-sops.sh <host>` (no `--clean`) | system already built |

______________________________________________________________________

## 🧰 `nixos-manager.sh` — rebuilds, cache, and updates

Interactive menu (or direct command mode) for day-to-day flake
maintenance: rebuilds, cache cleanup, updates, rollbacks, flake checks,
and branch management. It lives in the **repository root**
(`./nixos-manager.sh`) and expects a Git repository in `$NIXOS_DIR` (by
default, the directory containing the script).

### Uso

```bash
./nixos-manager.sh                    # open the interactive menu
./nixos-manager.sh <option>           # run directly: legacy | flake | clean | update | generation
./nixos-manager.sh <option> <host>    # run for a specific host: flake dell
NIXOS_FLAKE_ATTR=dell ./nixos-manager.sh flake   # set the host through an environment variable
```

### Menu options

| # | Keyword | Action |
|---|---|---|
| 0 | `setup` | Initial setup on a new machine (symlink `/etc/nixos` to the repo, clone if needed, detect the host) |
| 1 | `legacy` | Build without flakes (`nixos-rebuild switch`, using `/etc/nixos` through the symlink) |
| 2 | `flake` | Flake build — complete workflow: select branch → checkout → commit pending changes → pull → rebuild → push |
| 3 | `clean` | Clean the store: *Quick* mode (generations older than 14 days) or *Aggressive* (`nix-collect-garbage -d`), then optionally sync the bootloader |
| 4 | `update` | Update the system (same Git workflow as `flake`, plus `nix flake update`) |
| 5 | `dry` | Test build (does not activate the configuration) |
| 6 | `rollback` | Roll back to the previous generation (`nixos-rebuild switch --rollback`) |
| 7 | `check` | Run `nix flake check --print-build-logs`, optionally for a specific host |
| 8 | `hosts` | List the hosts configured in the flake and which one matches this machine |
| 9 | `branches` | List local and remote branches, marking the current branch and local branches missing from `origin` |
| a | `prune` | Remove local branches with no matching branch on `origin` (the default and current branches are never candidates) |
| g | `generation` | Show the latest system generation (Nix profile + bootloader entries) |
| m | `home` / `macbook` | **Physical MacBook M2 only**: `home-manager switch --flake ".#borba@macbook"` — standalone, not `nixos-rebuild` (no sudo, bootloader, or system generation) |
| c | `cleanmac` / `macclean` | **Physical MacBook M2 only**: clean Home Manager generations (`nix-collect-garbage`, Quick/Aggressive) + optimize the store — like `clean` (3), but without sudo or bootloader sync |
| q | `quit` | Exit |

### Known hosts (flake attribute → actual hostname)

| Flake attribute | Hostname | Label |
|---|---|---|
| `mac2011` | `mac2011` | MacBook Pro 13in (2011) |
| `dell` | `dell1564` (legacy alias: `dell1456`) | Dell Inspiron 1564 |
| `m2utm` | `macutm` | MacBook M2 - UTM |
| `macvmf` | `macvmf` | MacBook M2 - VMware Fusion |

> ⚠️ `macbook` (physical MacBook M2) is **not** in this table — it is not
> a `nixosConfiguration`, so it has no flake attribute in this sense.
> Options `m`/`c` call `homeConfigurations."borba@macbook"` directly and
> do not use the host detection/selection flow used by `flake`, `update`,
> `dry`, etc.

### Important behavior

- **The host is never assumed**: if it is not provided as an argument or
  through `NIXOS_FLAKE_ATTR`, the script always asks — even if the current
  machine's hostname matches a known host. This avoids rebuilding the
  wrong host when running remotely, for example over SSH from another
  machine.
- **The branch is also never assumed** when more than one is available:
  if only the default branch (`main`) exists, the script continues without
  asking; if other local or remote branches exist, it always asks which
  one to use for every `flake`/`update` run, not just the first time.
- **Dell (low RAM)**: builds are forced to run serially to avoid the OOM
  killer, using extra flags from `rebuild_extra_flags()`.
- **Cache cleanup** always offers to sync the bootloader
  (`nixos-rebuild boot`) after removing old generations; otherwise, the
  boot menu may continue listing entries for generations that no longer
  exist.

______________________________________________________________________

## 🪟 `tmux-devshell` / `zellij-devshell` — devshell profiles in any project

These commands open a tmux or Zellij session (using the same profile
system in both) with one window/tab per Nix devshell, based on a predefined
profile (a devshell combination) or a custom selection.

The scripts live in the **repository root** (`./scripts/tmux-devshell.sh`,
`./scripts/zellij-devshell.sh`) and are also **installed as commands**
(`~/.local/bin/tmux-devshell` through `home/modules/tmux.nix`,
`~/.local/bin/zellij-devshell` through `home/modules/zellij.nix`;
`home/modules/zsh.nix` adds
`$HOME/.local/bin` to `PATH`). Run them from **any project** under
`$HOME/prj/<something>` — the project does not need to be inside
nixos-config, and no path argument is required:

```bash
cd ~/prj/minha-api
tmux-devshell rust+postgres      # or: zellij-devshell rust+postgres
```

The devshells still come from nixos-config (located through
`NIXOS_CONFIG_DIR`, defaulting to `$HOME/nixos-config`), but each
window/tab uses the project directory from which the command was run as
its `cwd` — that is where `cargo build`, `go build`, etc. actually run.

### Usage

```bash
tmux-devshell                # interactive menu, starting in the current project
tmux-devshell --clean        # kill the existing session before creating a new one
tmux-devshell go+maria       # skip the menu and use the profile directly

zellij-devshell                # same, using Zellij
zellij-devshell --clean
zellij-devshell go+maria
```

### Predefined profiles

| Profile | Devshells |
|---|---|
| `go+maria` | go, mariadb |
| `go+postgres` | go, postgresql |
| `rust+postgres` | rust, postgresql |
| `rust+maria` | rust, mariadb |
| `lua+sqlite` | lua, sqlite |
| `python+mongo` | python, mongodb |
| `fullstack` | go, rust, postgresql, mariadb |

In addition to these profiles, the menu's **custom** option lets you
select any combination of directories under `devshells/`, including
`arduino` and `latex` (not included in a predefined profile) and
`rust+sqlite`/`go+sqlite` (which do not yet have dedicated profiles and
are available only through custom selection).

> `go`/`rust`/`python` are **language-only** shells (they do not include
> Postgres/MariaDB/SQLite). Use a profile or a custom selection to
> combine a language with the database you need for a project. One
> exception: if a project uses a crate/library that **links** against the
> database's native library at build time (e.g. `sqlx`/`diesel` without
> the `bundled` feature), running the database in a separate tab is not
> enough — the library must be available in the build shell.

### Requirements and fallback

- **`fzf`** (optional, recommended): enables a visual selector for both
  profile selection and custom devshell combinations, with a preview of
  the devshells included in each profile.
- **Without `fzf`**: the scripts fall back to a numbered terminal menu —
  no functionality is lost; only the selection experience changes.
- **`tmux-devshell`**: requires `tmux`.
- **`zellij-devshell`**: requires `zellij`. Each tab uses
  `default_tab_template` (tab bar + status bar), matching Zellij's default
  layout; without it, tabs have no bars.

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `NIXOS_CONFIG_DIR` | `$HOME/nixos-config` | Location of nixos-config, used to find `devshells/` |
| `DEVSHELLS_DIR` | `$NIXOS_CONFIG_DIR/devshells` | Directory containing the devshell subdirectories |
| `PROJECT_DIR` | `$(pwd)` when the command is run | The actual `cwd` for each window/tab — usually a project under `$HOME/prj/<something>` |
| `SESSION_PREFIX` | `dev` | Session name prefix (e.g. `dev-my-api-go+maria` — includes the project name to avoid collisions between projects using the same profile) |

______________________________________________________________________

## 🛠️ Development Shells

Development environments are organized in dedicated folders under
[devshells](devshells), each with its own flake. You can enter them
directly from the repository without changing the main flake
configuration, or use `tmux-devshell`/`zellij-devshell` (above) to open
several at once from any project directory.

### Available environments

```bash
# Go (pure — combine with a db devshell via tmux-devshell/zellij-devshell profiles)
nix develop ./devshells/go

# Rust (pure — combine with a db devshell via tmux-devshell/zellij-devshell profiles)
nix develop ./devshells/rust

# Lua
nix develop ./devshells/lua

# Python (uv2nix)
nix develop ./devshells/python

# Arduino
nix develop ./devshells/arduino

# LaTeX
nix develop ./devshells/latex

# PostgreSQL (server + psql/pgcli)
nix develop ./devshells/postgresql

# MariaDB (server + mycli)
nix develop ./devshells/mariadb

# SQLite (sqlite3 + analyzer + docs)
nix develop ./devshells/sqlite

# MongoDB
nix develop ./devshells/mongodb

# Pure Only
nix develop path:.
```

### Usage notes

- Each folder contains its own `flake.nix` defining that toolchain or database.
- The shell name is usually the same as the folder name, so `nix develop ./devshells/go` works as expected.
- `go`/`rust`/`python` are language-only shells — no database tooling baked in. Combine with a db devshell (`postgresql`, `mariadb`, `sqlite`, `mongodb`) via a `tmux-devshell`/`zellij-devshell` profile, or run both `nix develop` shells side by side manually.
- This keeps each environment isolated and easier to maintain.

**Advantages:**

- ✅ Isolated environments per stack
- ✅ Specific tool versions per language/database
- ✅ Reproducible across machines
- ✅ No need to modify the main flake for day-to-day use

______________________________________________________________________

## ⌨️ Logitech K380 Bluetooth pairing (Linux)

`logitech-k380-bluetooth-linux-fix/` contains a standalone `expect` script
(outside the flake; it runs on any distribution with
`bluetoothctl`/`bluez`) to work around the K380 keyboard pairing issue:
the standard `bluetoothctl` prompt displays the PIN only briefly (~10s),
and the K380 needs more time to enter it.

```bash
cd logitech-k380-bluetooth-linux-fix
chmod +x pair_k380.exp
./pair_k380.exp        # capture and display the PIN; allow 60 seconds to enter it on the keyboard
```

Requires `expect` and `bluez` (`bluetooth`/`bluez` on the host). See
`pair_k380_auto.exp` for a non-interactive variant and the
[dedicated README](logitech-k380-bluetooth-linux-fix/README.md) for
troubleshooting (keyboard reset, manual reconnection with
`bluetoothctl connect <MAC>`).

> This fix handles the pairing handshake itself. For the NixOS-specific
> behavior of the `mac2011` Bluetooth controller (classic Broadcom
> BR/EDR), see
> `hardware.bluetooth.settings.General.ControllerMode = lib.mkForce "bredr"`
> in `hosts/mac2011/configuration.nix`.

______________________________________________________________________

## 📚 Other docs in this repo

- [`docs/DENDRITIC-PATTERN.md`](docs/DENDRITIC-PATTERN.md) — an
  aspirational reference. The repository uses shared profiles, modules,
  and `enable` options for some capabilities, but does not literally
  implement the `core.nix` and `modules/category/default.nix` aggregator
  structure described there. Its example tree and hosts are not the source
  of truth for the current state; see this README and `flake.nix`.
- [`docs/architecture.md`](docs/architecture.md) — a conceptual overview
  of the repository's layers. For current paths and implementation,
  check the tree and the corresponding profiles/modules.
- [`scripts/age-key-backup-e-restauracao.md`](scripts/age-key-backup-e-restauracao.md)
  — step-by-step guide to backing up/restoring the age key (complements
  `scripts/backup-age-key.sh`).

______________________________________________________________________

```text
https://git.voidarc.co.uk/voidarc/nixos
```

## Architecture

See `docs/architecture.md` for the separation between system
configuration, development tooling, devshells, and Home Manager.
