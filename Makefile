# ==========================================
# NixOS Infra Makefile (NO FLAKES)
# ==========================================

NIXOS_CONFIG ?= $(HOME)/nixos-config

.PHONY: help build switch switch-off upgrade gc gc-hard fmt status flatpak-update

help:
	@echo "NixOS Infra Commands (no flakes)"
	@echo ""
	@echo "  make build            -> nixos-rebuild build"
	@echo "  make switch           -> rebuild keeping graphical session (allow unfree)"
	@echo "  make switch-off       -> rebuild in multi-user.target (safe, allow unfree)"
	@echo "  make upgrade          -> rebuild with channel upgrade (allow unfree)"
	@echo "  make gc               -> nix garbage collection"
	@echo "  make gc-hard          -> aggressive garbage collection"
	@echo "  make fmt              -> format nix files"
	@echo "  make status           -> systemd user jobs"
	@echo "  make flatpak-update   -> update all flatpaks"

# ------------------------------------------
# Build only (no activation)
# ------------------------------------------
build:
	sudo nixos-rebuild build \
		-I nixos-config=$(NIXOS_CONFIG)

# ------------------------------------------
# Normal rebuild (graphical session, allow unfree)
# ------------------------------------------
switch:
	sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch \
		-I nixos-config=$(NIXOS_CONFIG)

# ------------------------------------------
# Safe rebuild (drop to multi-user.target, allow unfree)
# ------------------------------------------
switch-off:
	sudo systemctl isolate multi-user.target
	sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch \
		-I nixos-config=$(NIXOS_CONFIG)
	sudo systemctl isolate graphical.target

# ------------------------------------------
# Upgrade system (channels, allow unfree)
# ------------------------------------------
upgrade:
	sudo nix-channel --update
	sudo NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch \
		-I nixos-config=$(NIXOS_CONFIG)

# ------------------------------------------
# Garbage collection
# ------------------------------------------
gc:
	sudo nix-collect-garbage

gc-hard:
	sudo nix-collect-garbage -d --delete-older-than 1d

# ------------------------------------------
# Formatting
# ------------------------------------------
fmt:
	nix fmt
	git status

# ------------------------------------------
# Debug helpers
# ------------------------------------------
status:
	systemctl --user list-jobs

# ------------------------------------------
# Flatpak update
# ------------------------------------------
flatpak-update:
	flatpak update -y
