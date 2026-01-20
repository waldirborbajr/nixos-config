# =========================================================
# NixOS Maintenance Makefile
# Repo-based (no /etc/nixos, no flakes, no Home Manager)
# =========================================================

CONFIG_DIR ?= $(HOME)/nixos-config

.PHONY: help switch build rollback \
        channels gc-soft gc-hard optimise verify \
        doctor generations space

# ---------------------------------------------------------
# Help
# ---------------------------------------------------------
help:
	@echo ""
	@echo "NixOS Maintenance Makefile"
	@echo ""
	@echo "Build / Switch:"
	@echo "  make switch        - Rebuild & switch system"
	@echo "  make build         - Build system only"
	@echo "  make rollback      - Rollback to previous generation"
	@echo ""
	@echo "Channels:"
	@echo "  make channels      - Update nix channels"
	@echo ""
	@echo "Garbage Collection:"
	@echo "  make gc-soft       - GC older than 7 days"
	@echo "  make gc-hard       - Full GC (delete all old generations)"
	@echo ""
	@echo "Store Maintenance:"
	@echo "  make optimise      - Deduplicate Nix store"
	@echo "  make verify        - Verify store integrity"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make doctor        - System health overview"
	@echo "  make generations   - List system generations"
	@echo "  make space         - Disk usage overview"
	@echo ""

# ---------------------------------------------------------
# Build / Switch
# ---------------------------------------------------------
build:
	sudo nixos-rebuild build \
		-I nixos-config=$(CONFIG_DIR)

switch:
	sudo nixos-rebuild switch \
		-I nixos-config=$(CONFIG_DIR)

rollback:
	sudo nixos-rebuild switch --rollback \
		-I nixos-config=$(CONFIG_DIR)

# ---------------------------------------------------------
# Channels
# ---------------------------------------------------------
channels:
	@echo ">> Updating Nix channels..."
	sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixpkgs-unstable || true
	sudo nix-channel --update

# ---------------------------------------------------------
# Garbage Collection
# ---------------------------------------------------------
gc-soft:
	sudo nix-collect-garbage --delete-older-than 7d

gc-hard:
	sudo nix-collect-garbage -d

# ---------------------------------------------------------
# Store Maintenance
# ---------------------------------------------------------
optimise:
	sudo nix store optimise

verify:
	sudo nix-store --verify --check-contents

# ---------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------
generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

space:
	@echo ">> Disk usage:"
	df -h /
	@echo ""
	@echo ">> Nix store size:"
	du -sh /nix/store

doctor:
	@echo ">> Nix version:"
	nix --version || true
	@echo ""
	@echo ">> Active system generation:"
	readlink /nix/var/nix/profiles/system
	@echo ""
	@echo ">> GC timers:"
	systemctl list-timers | grep nix || true
	@echo ""
	@echo ">> Docker:"
	systemctl is-active docker || true
	@echo ""
	@echo ">> K3s:"
	systemctl is-active k3s || true
	@echo ""
	@echo ">> Store size:"
	du -sh /nix/store
	@echo ""
	@echo ">> Doctor finished"
