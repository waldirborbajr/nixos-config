# Wallpapers

Custom wallpapers for NixOS configurations.

## Available Wallpapers

### devops-dark.svg
Custom DevOps-themed wallpaper with Catppuccin Mocha color scheme.

**Features:**
- 1920x1080 resolution (SVG, scales to any resolution)
- Catppuccin Mocha color palette (matches niri theme)
- DevOps pipeline visualization (CODE → BUILD → TEST → DEPLOY → MONITOR)
- Technology badges: Docker, Kubernetes, Nix, Terraform, ArgoCD, Ansible, Prometheus, Grafana, GitLab CI, Jenkins
- Dark background optimized for productivity

**Usage:**
This wallpaper is automatically configured for niri on macbook host.
The file is symlinked to `~/.config/niri/wallpaper.svg` via home-manager.

## Adding New Wallpapers

1. Add your wallpaper file to this directory
2. Update `modules/desktops/niri/default.nix` to include the new wallpaper
3. Update `modules/desktops/niri/layout.nix` to use the new wallpaper in `spawn-at-startup`

## Converting SVG to PNG (if needed)

```bash
# Using inkscape
inkscape -w 1920 -h 1080 devops-dark.svg -o devops-dark.png

# Using ImageMagick
convert -density 300 -resize 1920x1080 devops-dark.svg devops-dark.png
```
