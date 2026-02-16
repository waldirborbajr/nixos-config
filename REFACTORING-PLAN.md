# Module Refactoring Plan - wiprefact Branch

## Overview
Reorganizing modules into:
- **`modules/core/`** - System-level (NixOS) configurations
- **`modules/home/`** - Home-manager configurations (each in its own folder)

## Current Structure → New Structure

### System Core Modules → `modules/core/`

```
modules/system/          → modules/core/system/
├── audio.nix
├── base.nix
├── default.nix
├── fonts.nix
├── hm-gtk-compat.nix
├── networking.nix
├── nixpkgs.nix
├── no-sleep.nix
├── secrets.nix
├── serial-devices.nix
├── ssh.nix
└── system-packages.nix

modules/desktops/        → modules/core/desktops/
├── gnome.nix
├── i3.nix
└── niri/

modules/features/        → modules/core/features/
├── devops.nix
├── qemu.nix
└── tailscale.nix

modules/virtualization/  → modules/core/virtualization/
├── default.nix          (system-level only)
├── docker.nix
├── podman.nix
├── k3s.nix
└── libvirt.nix
Note: virtualbox.nix & distrobox.nix → modules/home/ (they're home-manager modules)

modules/languages/       → modules/core/languages/
├── default.nix
├── nodejs.nix           (system-level)
├── python.nix           (system-level)
├── go.nix
├── lua.nix
├── nix-dev.nix
└── rust.nix

modules/users/           → modules/core/users/
└── borba.nix

modules/autologin.nix    → modules/core/autologin.nix
modules/xdg-portal.nix   → modules/core/xdg-portal.nix
```

### Home-Manager Modules → `modules/home/`

Each app gets its own folder with a `default.nix`:

```
modules/apps/alacritty.nix        → modules/home/alacritty/default.nix
modules/apps/bat.nix              → modules/home/bat/default.nix
modules/apps/browsers.nix         → modules/home/browsers/default.nix
modules/apps/chirp.nix            → modules/home/chirp/default.nix
modules/apps/clipboard.nix        → modules/home/clipboard/default.nix
modules/apps/commitizen.nix       → modules/home/commitizen/default.nix
modules/apps/communication.nix    → modules/home/communication/default.nix
modules/apps/dev-tools.nix        → modules/home/dev-tools/default.nix
modules/apps/fastfetch.nix        → modules/home/fastfetch/default.nix
modules/apps/fun-tools.nix        → modules/home/fun-tools/default.nix
modules/apps/fzf.nix              → modules/home/fzf/default.nix
modules/apps/git.nix              → modules/home/git/default.nix
modules/apps/helix.nix            → modules/home/helix/default.nix
modules/apps/ides.nix             → modules/home/ides/default.nix
modules/apps/knowledge.nix        → modules/home/knowledge/default.nix
modules/apps/latex.nix            → modules/home/latex/default.nix
modules/apps/lazygit.nix          → modules/home/lazygit/default.nix
modules/apps/micro.nix            → modules/home/micro/default.nix
modules/apps/neovim.nix           → modules/home/neovim/default.nix
modules/apps/network-manager.nix  → modules/home/network-manager/default.nix
modules/apps/nix.nix              → modules/home/nix/default.nix
modules/apps/remote.nix           → modules/home/remote/default.nix
modules/apps/ripgrep.nix          → modules/home/ripgrep/default.nix
modules/apps/screens.nix          → modules/home/screens/default.nix
modules/apps/ssh-tools.nix        → modules/home/ssh-tools/default.nix
modules/apps/starship.nix         → modules/home/starship/default.nix
modules/apps/swaync.nix           → modules/home/swaync/default.nix
modules/apps/termius.nix          → modules/home/termius/default.nix
modules/apps/tmux.nix             → modules/home/tmux/default.nix
modules/apps/wezterm.nix          → modules/home/wezterm/default.nix
modules/apps/yazi.nix             → modules/home/yazi/default.nix
modules/apps/zellij.nix           → modules/home/zellij/default.nix

# Existing folders - keep structure
modules/apps/zsh/                 → modules/home/zsh/
modules/apps/p10k/                → modules/home/p10k/
modules/apps/media/               → modules/home/media/
modules/apps/productivity/        → modules/home/productivity/

# Other home-manager modules
modules/themes/                   → modules/home/themes/
modules/languages/nodejs-home.nix → modules/home/languages/nodejs.nix
modules/languages/python-home.nix → modules/home/languages/python.nix
modules/virtualization/virtualbox.nix → modules/home/virtualbox/default.nix
modules/virtualization/distrobox.nix  → modules/home/distrobox/default.nix

# Aggregator
modules/apps/default.nix          → modules/home/default.nix (updated imports)
```

### Additional Files to Copy/Move

```
modules/apps/TMUX-KEYBINDINGS.md → modules/home/tmux/KEYBINDINGS.md
modules/apps/WEZTERM-INFO.md     → modules/home/wezterm/INFO.md
modules/apps/YAZI-MIGRATION.md   → modules/home/yazi/MIGRATION.md
modules/apps/config.jsonc        → modules/home/yazi/config.jsonc (if related to yazi)
```

## Files That Need Import Updates

After moving modules, these files need their imports updated:

### System-level configs:
- `flake.nix`
- `hosts/dell.nix`
- `hosts/macbook.nix`
- `profiles/desktop.nix`
- `profiles/developer.nix`
- `profiles/minimal.nix`
- `core.nix` (if it imports system modules)
- `home.nix` (if it imports system modules)

### Example Import Changes:

**Before:**
```nix
imports = [
  ./modules/system
  ./modules/desktops/gnome.nix
  ./modules/features/tailscale.nix
];
```

**After:**
```nix
imports = [
  ./modules/core/system
  ./modules/core/desktops/gnome.nix
  ./modules/core/features/tailscale.nix
];
```

**Before:**
```nix
imports = [
  ./modules/apps
  ./modules/themes
];
```

**After:**
```nix
imports = [
  ./modules/home
  ./modules/home/themes
];
```

## Benefits

1. **Clear Separation**: System-level vs user-level configuration
2. **Better Organization**: Each home app in its own folder
3. **Easier to Navigate**: Logical grouping
4. **Future-proof**: Room for additional files (configs, docs) per module
5. **Standard Pattern**: Follows common Nix/NixOS conventions

## Execution Steps

1. ✅ Create wiprefact branch
2. ✅ Analyze current structure
3. Create new directory structure
4. Move/copy system core modules
5. Move/copy home-manager modules (create folders for each .nix file)
6. Update all imports
7. Test build
8. Commit if successful

## Estimated Changes

- ~50+ files to move
- ~10+ files to update imports
- Creates clear module boundaries
