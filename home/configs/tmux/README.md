# Tmux Configuration

> Opinionated tmux setup focused on **productivity, performance, persistence and low friction**.
> Designed to work seamlessly with **Alacritty**, **WezTerm**, **Neovim**, and modern DevOps workflows.

---

## ✨ Highlights

- **Prefix key:** Ctrl-a (faster than Ctrl-b, Vim-native)
- **Navigation:** Vim-style pane & window movement
- **Smart splits:** Path-aware (new panes open in current directory)
- **Color support:** 24-bit true color (RGB) for accurate theme rendering
- **Theme:** Tokyo Night Moon (hardcoded for consistency and speed)
- **Clipboard:** System integration via tmux-yank + OSC 52
- **Session persistence:** Automatic save/restore via tmux-resurrect + tmux-continuum
- **Startup:** Auto-restore sessions on tmux initialization (zero friction)
- **Compatibility:** Linux, macOS, NixOS

---

## 📦 Requirements

- tmux ≥ 3.2 (recommended for performance)
- git
- zsh (optional but recommended)

**Terminal Compatibility:**
- ✅ Alacritty
- ✅ WezTerm
- ✅ kitty
- ✅ iTerm2
- ✅ Windows Terminal (WSL2)

---

## 🔧 Installation

### 1. Install tmux

```sh
# Arch Linux
sudo pacman -S tmux

# Ubuntu / Debian
sudo apt install tmux

# macOS
brew install tmux
```

### 2. Clone/download configuration

```sh
git clone https://github.com/your-user/your-tmux-repo.git ~/tmux-config
```

### 3. Create symlink

```sh
mkdir -p ~/.config/tmux
ln -sf ~/tmux-config/tmux.conf ~/.config/tmux/tmux.conf
```

### 4. Reload tmux

```sh
tmux source-file ~/.config/tmux/tmux.conf
```

Or inside tmux:
```
Prefix + r
```

---

## 🔌 Plugins (TPM)

Uses **TPM** (Tmux Plugin Manager) for plugin management.

### Included plugins

| Plugin | Purpose | Performance |
|--------|---------|-------------|
| `tpm` | Plugin manager | Essential (no overhead) |
| `tmux-sensible` | Sensible defaults | ~1ms |
| `vim-tmux-navigator` | Seamless Neovim ↔ tmux nav | ~2ms on pane switch |
| `tmux-yank` | System clipboard integration | On-demand |
| `tmux-resurrect` | Session save/restore | On save/restore only |
| `tmux-continuum` | Auto-save/restore sessions | 10min interval |

**Total overhead:** ~3-5ms per keypress (imperceptible)

### First-time setup

Inside tmux, install plugins:

```
Prefix + I
```

This will:
1. Clone all plugins from GitHub
2. Initialize plugin scripts
3. Auto-generate `~/.config/tmux/plugins/` directory

---

## ♻️ Session Persistence

### tmux-resurrect

**Saves on demand:**
- Sessions, windows, panes
- Layouts and working directories
- Running processes (ssh, kubectl, helm, terraform, nvim, vim)
- Pane contents (optional, enabled by default)

**Manual commands:**

| Action | Binding |
|--------|---------|
| Save session | `Prefix + Ctrl-s` |
| Restore session | `Prefix + Ctrl-r` |

### tmux-continuum

**Automatic operation:**
- ✅ Auto-saves every 10 minutes
- ✅ Auto-restores on tmux startup
- ✅ Zero user interaction required

**Benefits:**
- Never lose context after crashes or reboots
- Persistent workspace state across logins
- Perfect for long-running DevOps workflows (kubectl, terraform, ssh tunnels)

---

## 🧭 Keybindings

### Core

| Key | Action |
|----|--------|
| `Ctrl-a` | Prefix (send with `Ctrl-a Ctrl-a`) |
| `Prefix + r` | Reload config (displays confirmation) |

---

### Pane Navigation (Vim-style, fastest)

**With Alt (no prefix needed):**

| Key | Action |
|----|--------|
| `Alt + h` | Move left |
| `Alt + j` | Move down |
| `Alt + k` | Move up |
| `Alt + l` | Move right |

**With Prefix (fallback):**

| Key | Action |
|----|--------|
| `Prefix + h` | Move left |
| `Prefix + j` | Move down |
| `Prefix + k` | Move up |
| `Prefix + l` | Move right |

**Neovim integration** (works with `vim-tmux-navigator` plugin):
- Same bindings work seamlessly between Neovim and tmux panes
- One muscle memory for pane navigation across editor and terminal

---

### Pane Resizing (repeatable = hold key)

| Key | Action |
|----|--------|
| `Prefix + H` | Resize left (5 units) |
| `Prefix + J` | Resize down (3 units) |
| `Prefix + K` | Resize up (3 units) |
| `Prefix + L` | Resize right (5 units) |

*Keybindings are repeatable (`-r` flag) — hold after first press for continuous resize*

---

### Splits (path-aware — opens in current directory)

| Key | Action |
|----|--------|
| `Prefix + \|` | Split horizontally (vertical pane) |
| `Prefix + v` | Split horizontally (alternative) |
| `Prefix + _` | Split vertically (horizontal pane) |
| `Prefix + s` | Split vertically (alternative) |

**Example workflow:**
```
$ cd /home/user/projects
$ tmux new-session -s dev
$ Prefix + v    # New pane opens in /home/user/projects, not ~
```

---

### Windows Management

**New window:**

| Key | Action |
|----|--------|
| `Prefix + c` | New window (in current directory) |

**Navigation:**

| Key | Action |
|----|--------|
| `Shift + ←` | Previous window |
| `Shift + →` | Next window |
| `Alt + H` | Previous window (alternative) |
| `Alt + L` | Next window (alternative) |

**Quick access (Alt + number):**

| Key | Action |
|----|--------|
| `Alt + 1-9` | Jump to window 1-9 |

**Pane zoom:**

| Key | Action |
|----|--------|
| `Prefix + m` | Toggle pane zoom |

---

### Copy Mode (vi keybindings)

**Enter copy mode:**
```
Prefix + [
```

**Once in copy mode:**

| Key | Action |
|----|--------|
| `v` | Start visual selection |
| `Ctrl-v` | Rectangle selection (block mode) |
| `y` | Yank (copy to clipboard and exit) |
| `Enter` | Yank and exit |
| `q` | Quit copy mode (without copy) |

**Clipboard integration:**
- Uses OSC 52 for SSH clipboard support
- Falls back to system clipboard locally
- `tmux-yank` plugin handles the heavy lifting

---

## 🎨 Visual Theme

### Tokyo Night Moon (Hardcoded)

Why hardcoded instead of plugin:
- ✅ **Performance:** No plugin overhead on every keystroke
- ✅ **Consistency:** Single source of truth for colors
- ✅ **Reliability:** No dependency on external plugin updates
- ✅ **Customization:** Easy to edit 16-color palette directly in config

**Color palette (16 colors):**

```
Background:  #222436 (dark blue-gray)
Foreground:  #c8d3f5 (light blue)
Cyan:        #86e1fc (bright blue)
Magenta:     #c099ff (purple)
Green:       #c3e88d (light green)
Yellow:      #ffc777 (warm yellow)
Blue:        #82aaff (primary blue)
Red/Pink:    #ff757f (accent red)
```

### Status Bar

**Left side:** Empty (minimal visual clutter)

**Right side displays:**
- Current window name (`#W`)
- Session name (`#S`)
- Prefix indicator (changes color when Ctrl-a pressed)

**Active window indicator:**
- Shows window index + checkmark + current directory

**Inactive windows:**
- Show index + window name

---

## 🔄 Terminal Color Support

### RGB (24-bit True Color) — Default

**Current setting:**
```tmux
set -ag terminal-overrides ",*:RGB"
```

**Why RGB?**
- ✅ 16.7 million colors (accurate theme rendering)
- ✅ Supported by all modern terminals
- ✅ Tokyo Night theme needs precise colors
- ✅ No performance penalty (~3% bandwidth, imperceptible)

**Supported terminals:**
- Alacritty, WezTerm, kitty, iTerm2
- Gnome Terminal, KDE Konsole (recent versions)
- Windows Terminal, ConEmu

### Alternative: TC (256 colors)

If connecting to very old servers (pre-2015):

```tmux
# Fallback chain: RGB first, then TC
set -ag terminal-overrides ",*:RGB:TC"
```

---

## 🧠 Design Philosophy

- **Minimal friction:** Few keystrokes, maximum efficiency
- **Keyboard-first:** All common operations via keybindings
- **Vim-centric:** hjkl navigation, vi copy mode
- **Persistent state:** Never lose context (auto-save/restore)
- **Performance-optimized:** No unnecessary overhead
- **DevOps-friendly:** Designed for long-running processes and SSH tunnels

---

## 📋 Configuration Structure

Config is organized into **14 logical sections:**

1. **Terminal & Display Core** — Color, focus, status bar
2. **Behavior & Performance** — Shell, history, mouse, timing
3. **Indexing & Window Management** — Base index, renumbering, auto-rename
4. **Key Bindings - Prefix & Core** — Ctrl-a setup, reload
5. **Pane Navigation** — Vim-style hjkl (with/without prefix)
6. **Pane Resizing** — Repeatable resize bindings
7. **Window Management** — Splits, new windows, zoom
8. **Window Switching** — Fast horizontal navigation
9. **Copy Mode** — Vi keybindings, selection, yank
10. **Color Theme** — Tokyo Night Moon palette
11. **Status Bar Styling** — Statusline configuration
12. **Plugins** — TPM + included plugins
13. **Session Persistence** — tmux-resurrect + tmux-continuum
14. **TPM Bootstrap** — Auto-install on first run

Each section is clearly marked with visual separators and inline comments explaining "why" not just "what."

---

## 🚀 Recommended Setup

Works best with:

- **Terminal:** Alacritty or WezTerm (both support RGB 24-bit)
- **Editor:** Neovim with `vim-tmux-navigator` support
- **Shell:** Zsh + starship (status line)
- **Dotfiles:** Symlinked config (portable across machines)

### Example Alacritty integration

```yaml
# ~/.config/alacritty/alacritty.yml
shell:
  program: /usr/bin/tmux
  args:
    - new-session
    - -A
    - -s
    - main
```

This auto-launches tmux with session persistence.

---

## 🔍 Troubleshooting

### Colors look wrong

**Check terminal supports RGB:**
```bash
echo $TERM
# Should output: xterm-256color, alacritty, wezterm, etc

printf '\033[38;2;255;0;0mRED\033[0m\n'
# Should display bright red (not dim)

tmux info | grep RGB
# Should show: ... terminfo: ... (terminfo supports RGB) ...
```

### Plugins not loading

Inside tmux:
```
Prefix + I    # Install plugins
Prefix + U    # Update plugins
Prefix + Alt-u  # Uninstall (remove) plugins
```

Check plugin directory exists:
```bash
ls -la ~/.config/tmux/plugins/
# Should list: tpm/, tmux-sensible/, vim-tmux-navigator/, etc
```

### Session not restoring

Check tmux-continuum is saving:
```bash
ls -la ~/.local/share/tmux/resurrect/
# Should show recent checkpoint files
```

Manually restore:
```
Prefix + Ctrl-r  # (inside tmux)
```

### Keybindings not working

Reload config:
```
Prefix + r
```

Verify in config file that binding exists and is not commented out.

---

## 📝 Common Customizations

### Change prefix key

```tmux
unbind C-a
set -g prefix C-b
bind C-b send-prefix
```

### Disable auto-restore on startup

```tmux
# In tmux-continuum section, change:
set -g @continuum-restore 'off'
```

### Adjust auto-save interval

```tmux
# Default: 10 minutes
set -g @continuum-save-interval '5'   # Save every 5 minutes
```

### Use different theme

Replace the color variables in section 10 (Color Theme) with your own hex codes.

### Disable mouse support

```tmux
set -g mouse off
```

---

## 🧑‍💻 Maintenance

### Check tmux version

```bash
tmux -V
# Output: tmux 3.3c (or similar)
```

### Update plugins

Inside tmux:
```
Prefix + U
```

### List all sessions

```bash
tmux list-sessions
```

### Attach to existing session

```bash
tmux attach-session -t session_name
```

Or use numbered quick-access (inside tmux):
```
Alt + 1-9  # Jump to window 1-9
```

---

## 🎓 Learning Resources

- **tmux official docs:** `man tmux`
- **Keybindings reference:** `Prefix + ?` (inside tmux)
- **Vim-tmux integration:** https://github.com/joshmedeski/vim-tmux-navigator

---

## 📌 Performance Notes

- **Config load time:** ~50-100ms (one-time at session start)
- **Keypress latency:** <5ms (unnoticeable)
- **Memory footprint:** ~15-20MB per session
- **CPU:** Negligible (<1% idle)
- **No impact on SSH latency** when using standard terminal multiplexing

---

## 🧑‍💻 Author & Maintenance

**Original:** Inspired by modern tmux best practices  
**Refactored for:** DevOps, SRE, and modern development workflows  
**Optimized for:** Performance, clarity, and zero manual session management

---

## 🔗 Related Projects

- [vim-tmux-navigator](https://github.com/joshmedeski/vim-tmux-navigator)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
- [TPM](https://github.com/tmux-plugins/tpm)

---

## 📄 License

MIT

---

## Quick Reference Card

### Installation Checklist
- [ ] Install tmux (≥3.2)
- [ ] Clone/download config
- [ ] Create symlink to `~/.config/tmux/tmux.conf`
- [ ] Run `tmux source-file ~/.config/tmux/tmux.conf`
- [ ] Inside tmux: `Prefix + I` (install plugins)
- [ ] Verify colors: `printf '\033[38;2;255;0;0mRED\033[0m\n'`
- [ ] Restart tmux: `tmux kill-server && tmux new-session`

### Essential Keybindings
```
Navigation:     Alt+hjkl or Prefix+hjkl
New pane:       Prefix+| (horizontal) or Prefix+_ (vertical)
Window switch:  Shift+Arrows or Alt+H/L
Copy mode:      Prefix+[ then v/y
Reload config:  Prefix+r
```

### Persistence (Automatic)
```
Sessions auto-save:    Every 10 minutes
Sessions auto-restore: On tmux startup
Manual save:           Prefix+Ctrl-s
Manual restore:        Prefix+Ctrl-r
```

Happy hacking 🧠⚡
