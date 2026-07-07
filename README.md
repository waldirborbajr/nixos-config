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

---

## 🚀 Recreating a host from scratch (order matters)

This section is for anyone (including future-you) who clones this repo onto
a brand-new machine and needs to know **exactly** what to run, and in what
order. Skipping a step or running them out of order is the most common
cause of a failed first `nixos-rebuild switch`.

### Why the order matters

This flake uses [SOPS](https://github.com/getsops/sops) to encrypt SSH keys
(`hosts/<host>/secrets/<host>.yaml`). `nixos-rebuild switch` decrypts that
file during activation using a local [age](https://github.com/FiloSottile/age)
key — but on a **genuinely fresh** machine, neither the age key nor the
encrypted secrets file exist yet, and the tools needed to create them
(`sops`, `age`, `jq`) only get installed *by* a successful rebuild. That's a
chicken-and-egg problem, and it's exactly what breaks if you jump straight
to step 4 below.

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
   Replace `<host>` with one of: `dell1456`, `mac2011`, `macutm` (aliases
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
   ./scripts/nixos-manager.sh setup      # symlinks /etc/nixos -> ~/nixos-config
   ./scripts/nixos-manager.sh flake      # select branch + host, then rebuild
   ```
   This is the first rebuild that can actually succeed, because the age key
   and encrypted secrets from step 3 already exist on disk. From here on,
   `sops`/`age`/`jq` are installed system-wide, and dotfiles for tmux, i3,
   alacritty, rofi, oh-my-posh, helix, git, and zsh are symlinked
   automatically via `systemd.tmpfiles.rules` — no manual `stow` needed.

**5. Re-running the SSH/SOPS script later (e.g. adding a new key, rotating
   an existing one) uses the same script *without* `--clean`:**
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
| 4 | `./scripts/nixos-manager.sh setup` then `flake` | steps 1–3 done |
| 5+ | `./scripts/manage-ssh-sops.sh <host>` (no `--clean`) | system already built |

---

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

---

```text
https://git.voidarc.co.uk/voidarc/nixos
```

