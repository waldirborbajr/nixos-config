# =========================================================
# NixOS / Flake Makefile (Multi-host / Multi-user)
# =========================================================

# -------- Variables --------
HOST ?= $(shell hostname)
FLAKE ?= .#$(HOST)
EXPERIMENTAL ?= --extra-experimental-features "nix-command flakes"

UNAME_S := $(shell uname -s)

# -------- Help --------
.PHONY: help
help:
	@echo ""
	@echo "Available targets:"
	@echo ""
	@echo "  nixos-rebuild     - Rebuild NixOS system for host ($(HOST))"
	@echo "  darwin-rebuild    - Rebuild nix-darwin system for host ($(HOST))"
	@echo "  rebuild           - Auto-detect OS and rebuild"
	@echo ""
	@echo "  flake-update      - Update flake inputs"
	@echo "  flake-check       - Check flake evaluation"
	@echo "  nix-gc            - Run garbage collection"
	@echo ""
	@echo "Usage examples:"
	@echo "  make nixos-rebuild HOST=dell"
	@echo "  make rebuild HOST=macbook"
	@echo ""

# -------- Rebuilds --------
.PHONY: nixos-rebuild
nixos-rebuild:
	@echo "Rebuilding NixOS configuration for host: $(HOST)"
	@sudo nixos-rebuild switch --flake $(FLAKE)
	@echo "NixOS rebuild complete."

.PHONY: darwin-rebuild
darwin-rebuild:
	@echo "Rebuilding nix-darwin configuration for host: $(HOST)"
	@sudo darwin-rebuild switch --flake $(FLAKE)
	@echo "Darwin rebuild complete."

.PHONY: rebuild
rebuild:
ifeq ($(UNAME_S),Linux)
	@$(MAKE) nixos-rebuild
else ifeq ($(UNAME_S),Darwin)
	@$(MAKE) darwin-rebuild
else
	@echo "Unsupported OS: $(UNAME_S)"
endif

# -------- Maintenance --------
.PHONY: nix-gc
nix-gc:
	@echo "Running Nix garbage collection..."
	@sudo nix-collect-garbage -d
	@echo "Garbage collection complete."

.PHONY: flake-update
flake-update:
	@echo "Updating flake inputs..."
	@nix flake update
	@echo "Flake update complete."

.PHONY: flake-check
flake-check:
	@echo "Checking flake..."
	@nix flake check
	@echo "Flake check complete."
