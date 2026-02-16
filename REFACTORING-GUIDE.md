# Module Refactoring - Execution Guide

## Overview

This refactoring reorganizes the NixOS configuration into a clear separation:
- **`modules/core/`** - System-level (NixOS) configurations
- **`modules/home/`** - Home-manager configurations (each module in its own folder)

## Files Created

1. **REFACTORING-PLAN.md** - Detailed plan showing before/after structure
2. **migrate-modules.sh** - Moves all module files to new locations
3. **update-imports.sh** - Updates all import paths in configuration files
4. **run-refactoring.sh** - Master script that runs everything in order
5. **REFACTORING-GUIDE.md** - This file

## Quick Start

### Option 1: Automatic (Recommended)

Run the complete refactoring with one command:

```bash
# Make executable
chmod +x run-refactoring.sh

# Run refactoring
./run-refactoring.sh
```

### Option 2: Step by Step

```bash
# Make scripts executable
chmod +x migrate-modules.sh update-imports.sh

# Step 1: Migrate module files  
./migrate-modules.sh

# Step 2: Update import paths
./update-imports.sh
```

## What Will Happen

### 1. Directory Structure Changes

**Before:**
```
modules/
├── apps/ (50+ files)
├── desktops/
├── features/
├── languages/
├── system/
├── themes/
├── users/├── virtualization/
├── autologin.nix
└── xdg-portal.nix
```

**After:**
```
modules/
├── core/
│   ├── desktops/
│   ├── features/
│   ├── languages/
│   ├── system/
│   ├── users/
│   ├── virtualization/
│   ├── autologin.nix
│   └── xdg-portal.nix
└── home/
    ├── alacritty/
    ├── bat/
    ├── browsers/
    ├── ... (50+ modules)
    ├── media/
    ├── productivity/
    ├── themes/
    ├── zsh/
    └── default.nix
```

### 2. Import Path Updates

**System configs will change from:**
```nix
imports = [ ./modules/system ];
```
**To:**
```nix
imports = [ ./modules/core/system ];
```

**Home-manager configs will change from:**
```nix
imports = [ ./modules/apps ];
```
**To:**
```nix
imports = [ ./modules/home ];
```

### 3. Files Modified

The scripts will update imports in:
- `core.nix`
- `home.nix`
- `profiles/minimal.nix`
- `profiles/desktop.nix`
- `profiles/developer.nix`
- `hosts/dell.nix`
- `hosts/macbook.nix`
- `modules/home/default.nix`
- All module files as needed

## After Refactoring

### 1. Review Changes

```bash
# See what files were moved/changed
git status

# See detailed diff (will be large!)
git diff --stat
```

### 2. Test Build

```bash
# Test without applying
sudo nixos-rebuild build --flake .#macbook
# or
sudo nixos-rebuild build --flake .#dell
```

### 3. If Build Succeeds

```bash
# Stage all changes
git add -A

# Commit with descriptive message
git commit -m "refactor: reorganize modules into core/ and home/ structure

- Move system-level configs to modules/core/
- Move home-manager configs to modules/home/  
- Each home app now in its own folder
- Update all import paths
- Improve module organization and maintainability"

# Optional: Push to remote
git push origin wiprefact
```

### 4. If Build Fails

```bash
# See what's wrong
sudo nixos-rebuild build --flake .#macbook --show-trace

# Revert if needed
git reset --hard HEAD

# Or fix specific issues and try again
```

## Rollback

If something goes wrong and you want to completely undo:

```bash
# Hard reset to before refactoring
git reset --hard HEAD

# Return to main branch
git checkout main

# Delete the refactoring branch
git branch -D wiprefact
```

## Benefits of New Structure

1. **Clear Separation**: System-level vs user-level configuration
2. **Better Organization**: Each home app in its own folder (room for configs, docs)
3. **Easier Navigation**: Logical grouping by responsibility
4. **Scalable**: Easy to add new modules
5. **Standard Pattern**: Follows NixOS community conventions
6. **Future-proof**: Each module can grow independently

## Troubleshooting

### Issue: "No such file or directory" during migration

**Solution**: Make sure you're running from the repository root:
```bash
cd /workspaces/nixos-config
./run-refactoring.sh
```

### Issue: Build fails with "module not found"

**Solution**: Check import paths were updated correctly:
```bash
grep -r "modules/apps" . --include="*.nix"
grep -r "modules/system" . --include="*.nix" --exclude-dir=modules
```

These should return no results if all imports were updated.

### Issue: Want to test one module at a time

**Solution**: Use git to selectively stage/test:
```bash
# Stage only specific modules
git add modules/core/system
git add modules/home/alacritty

# Test build
sudo nixos-rebuild build --flake .#macbook
```

## Questions?

Refer to [REFACTORING-PLAN.md](REFACTORING-PLAN.md) for detailed before/after structure.
