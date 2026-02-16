# Theme Management

Centralized theme configuration for the entire NixOS system.

## Overview

This module provides a single source of truth for theming across:
- **Terminal** (Alacritty)
- **File Manager** (Yazi)
- **Desktop Environments** (Niri, GNOME, i3)
- **CLI Tools** (bat, fzf, and more)
- **Cursor Theme** (Bibata-Modern-Ice)

## Current Theme: Catppuccin

**Flavor:** `mocha` (dark theme)  
**Accent:** `blue`

## Cursor Theme: Bibata-Modern-Ice

**Default Cursor:** `Bibata-Modern-Ice`  
**Size:** `24` pixels

### Changing Cursor Theme

To use a different cursor theme, configure in your home configuration:

```nix
theme.cursor = {
  enable = true;
  package = pkgs.bibata-cursors;  # or pkgs.vanilla-dmz, pkgs.capitaine-cursors, etc.
  name = "Bibata-Modern-Ice";     # Theme name
  size = 24;                       # Cursor size in pixels
};
```

Popular cursor themes available in nixpkgs:
- `bibata-cursors` - Bibata-Modern-Ice (default), Bibata-Modern-Classic, etc.
- `capitaine-cursors` - macOS-style cursor theme
- `vanilla-dmz` - DMZ cursor theme
- `nordzy-cursor-theme` - Nord-themed cursors
- `phinger-cursors` - Phinger cursors

### Available Flavors

- `latte` - Light theme ☀️
- `frappe` - Dark theme with warm tones 🌅
- `macchiato` - Dark theme with cooler tones 🌙
- `mocha` - Dark theme (default) 🌃

### Available Accents

`rosewater` | `flamingo` | `pink` | `mauve` | `red` | `maroon` | `peach` | `yellow` | `green` | `teal` | `sky` | `sapphire` | `blue` | `lavender`

## How to Change Theme

### Option 1: Change Flavor/Accent (Catppuccin)

Edit [`modules/themes/default.nix`](default.nix):

```nix
theme = {
  flavor = "macchiato";  # Change this
  accent = "lavender";   # Change this
};
```

### Option 2: Switch to Different Theme (e.g., Nord)

1. **Update [`flake.nix`](../../flake.nix):**

```nix
inputs = {
  # Replace catppuccin with nord
  # catppuccin.url = "github:catppuccin/nix";
  nord.url = "github:nordtheme/nix";  # hypothetical
};
```

2. **Update [`modules/themes/default.nix`](default.nix):**

```nix
config = lib.mkIf config.theme.enable {
  # Replace catppuccin configuration
  nord = {
    enable = true;
  };
};
```

3. **Update application modules:**

Replace `catppuccin.enable = true;` with `nord.enable = true;` in:
- [`modules/apps/terminals.nix`](../apps/terminals.nix)
- [`modules/apps/yazi.nix`](../apps/yazi.nix)
- Any other themed modules

4. **Rebuild:**

```bash
sudo nixos-rebuild switch --flake .#hostname
```

## Benefits

✅ **Single source of truth** - Change theme in one place  
✅ **Consistent across system** - All applications use the same theme  
✅ **Easy to switch** - Change flavors/accents without editing multiple files  
✅ **Type-safe** - Nix ensures valid theme configurations  
✅ **No duplicated colors** - Theme values come from official modules  

## Applications with Theme Support

| Application | Auto-themed | Location |
|-------------|-------------|----------|
| Alacritty   | ✅ | [`modules/apps/terminals.nix`](../apps/terminals.nix) |
| Yazi        | ✅ | [`modules/apps/yazi.nix`](../apps/yazi.nix) |
| Bat         | ✅ | [`modules/apps/shell.nix`](../apps/shell.nix) |
| FZF         | ✅ | [`modules/apps/shell.nix`](../apps/shell.nix) |
| Tmux        | ✅ | [`modules/apps/tmux.nix`](../apps/tmux.nix) |
| Git Delta   | ✅ | [`modules/apps/dev-tools.nix`](../apps/dev-tools.nix) |
| Niri        | ✅ | [`modules/desktops/niri/`](../desktops/niri/) |
| GNOME       | ✅ | [`modules/desktops/gnome.nix`](../desktops/gnome.nix) |
| Cursor      | ✅ | [`modules/themes/cursor.nix`](cursor.nix) |

## Resources

- [Catppuccin NixOS Module](https://github.com/catppuccin/nix)
- [Catppuccin Palette](https://github.com/catppuccin/catppuccin)
- [Supported Applications](https://github.com/catppuccin/nix#-supported-modules)

## Troubleshooting

### Theme not applied after rebuild

```bash
# Force home-manager rebuild
home-manager switch --flake .#hostname

# Or full system rebuild
sudo nixos-rebuild switch --flake .#hostname --impure
```

### Different flavors for different applications

Currently, the theme is applied globally. For per-application customization, you can override in specific modules:

```nix
programs.alacritty = {
  catppuccin = {
    enable = true;
    flavor = "latte";  # Override for this app only
  };
};
```
