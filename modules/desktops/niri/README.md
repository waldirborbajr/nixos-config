# Niri - Modular Configuration

This directory contains a modular Niri configuration, organized by responsibility for easier maintenance.

## Structure

```
modules/desktops/niri/
├── default.nix          # Main module, imports all sub-modules
├── config.nix           # Generates main config.kdl with includes
├── input.nix            # Input devices (keyboard, mouse, touchpad)
├── output.nix           # Monitor/display configuration
├── layout.nix           # Layout, gaps, borders, focus-ring, cursor
├── keybindings.nix      # All keyboard shortcuts
├── window-rules.nix     # Per-application window rules
├── animations.nix       # Animation settings and debug options
├── waybar.nix           # Waybar status bar configuration
├── mako.nix             # Mako notification daemon
├── fuzzel.nix           # Fuzzel application launcher
└── README.md            # This file
```

## Generated Configuration

The Nix modules generate the following structure in `~/.config/niri/`:

```
~/.config/niri/
├── config.kdl                    # Main config with includes
└── config.d/
    ├── input.kdl                 # Input configuration
    ├── output.kdl                # Output configuration
    ├── layout.kdl                # Layout configuration
    ├── keybindings.kdl           # Keybindings
    ├── window-rules.kdl          # Window rules
    └── animations.kdl            # Animations
```

## Usage

The modular configuration is imported through `modules/desktops/niri/default.nix`, which should be included in your home-manager configuration.

## Modifying Configuration

Each aspect of Niri's configuration is in its own file:

- **Input devices**: Edit `input.nix`
- **Monitors**: Edit `output.nix`
- **Visual appearance**: Edit `layout.nix`
- **Keyboard shortcuts**: Edit `keybindings.nix`
- **App-specific rules**: Edit `window-rules.nix`
- **Animations**: Edit `animations.nix`
- **Status bar**: Edit `waybar.nix`
- **Notifications**: Edit `mako.nix`
- **App launcher**: Edit `fuzzel.nix`

After modifying, rebuild with:
```bash
home-manager switch --flake .
```

## Benefits

- **Organized**: Each concern in its own file
- **Maintainable**: Easy to find and modify specific settings
- **Scalable**: Add new modules without cluttering existing ones
- **Reusable**: Modules can be easily shared or templated
- **Version control friendly**: Smaller diffs when changing settings

## Color Scheme

The configuration uses Catppuccin Mocha colors defined in `layout.nix`. To change the theme, modify the color definitions there.
