# 📜 Changelog

All notable changes to this repository are documented in this file.  
This project follows **Conventional Commits** and **Infra-Style Versioning**.

---

## [Unreleased]

### Added
- Initial project structure improvements
- Core Makefile refinements
- Feature flags for DEVOPS and QEMU support
- Unified hyprland desktop module with XDG config management

### Changed
- Refactor system-packages to include build tooling
- Flatten and simplify desktop modules
- Update performance defaults for MacBook and Dell

### Fixed
- Flake host validation logic
- Symlink user config behavior

### Removed
- Deprecated operations documentation (OPERATIONS.md)
- Legacy modules no longer in use

---

## [v1.0.0] — Initial Release

### Added
- Stable baseline configuration
- Multi-host NixOS support (MacBook, Dell)
- Performance and system modular organization
- Basic container support (Docker, Podman)
- Desktop environments: GNOME and Hyprland

### Changed
- Centralized system packages by responsibility
- Split container tooling into dedicated modules

### Removed
- Unused container runtimes from default system packages

---

## 📘 Changelog Rules

- Keep entries short and objective
- Group changes by type
- Do **not remove released entries**
- Always update before tagging a release

---

## 🧩 Commit Types Mapping

| Commit Type | Changelog Section |
|-------------|-------------------|
| `feat`      | Added             |
| `fix`       | Fixed             |
| `refactor`  | Changed           |
| `chore`     | Changed           |
| `docs`      | Documentation     |
