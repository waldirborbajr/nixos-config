# =========================================================
# NixOS / Flake Makefile (Single-machine focused)
# =========================================================

HOST ?= $(shell hostname)
FLAKE ?= .#$(HOST)
UNAME_S := $(shell uname -s)

# ---------------------------------------------------------
# Help
# ---------------------------------------------------------
.PHONY: help
help:
	@echo ""
	@echo "Rebuild:"
	@echo "  rebuild            Auto-detect OS and rebuild"
	@echo "  rebuild-dry        Dry-run rebuild (no changes)"
	@echo "  rollback           Rollback to previous generation"
	@echo ""
	@echo "Flakes:"
	@echo "  flake-update       Update flake inputs"
	@echo "  flake-check        Evaluate flake"
	@echo ""
	@echo "Garbage / Cleanup:"
	@echo "  gc-soft            Safe GC (old generations)"
	@echo "  gc-hard            Aggressive GC (everything unused)"
	@echo "  store-optimize     Deduplicate /nix/store"
	@echo ""
	@echo "Docker:"
	@echo "  docker-clean       Remove unused containers/images"
	@echo "  docker-nuke        Remove ALL unused data"
	@echo ""
	@echo "Diagnostics:"
	@echo "  store-size         Show /nix/store size"
	@echo "  store-top          Biggest closures"
	@echo "  diff-last          Diff last two generations"
	@echo ""

# ---------------------------------------------------------
# Rebuilds
# ---------------------------------------------------------
.PHONY: rebuild
rebuild:
ifeq ($(UNAME_S),Linux)
	sudo nixos-rebuild switch --flake $(FLAKE)
else ifeq ($(UNAME_S),Darwin)
	sudo darwin-rebuild switch --flake $(FLAKE)
endif

.PHONY: rebuild-dry
rebuild-dry:
	sudo nixos-rebuild dry-run --flake $(FLAKE)

.PHONY: rollback
rollback:
	sudo nixos-rebuild switch --rollback

# ---------------------------------------------------------
# Flake
# ---------------------------------------------------------
.PHONY: flake-update
flake-update:
	nix flake update

.PHONY: flake-check
flake-check:
	nix flake check

# ---------------------------------------------------------
# Garbage Collection
# ---------------------------------------------------------
.PHONY: gc-soft
gc-soft:
	@echo "Running safe garbage collection..."
	sudo nix-collect-garbage --delete-older-than 7d

.PHONY: gc-hard
gc-hard:
	@echo "Running aggressive garbage collection..."
	sudo nix-collect-garbage -d
	sudo nix-store --gc

.PHONY: store-optimize
store-optimize:
	@echo "Optimizing nix store..."
	sudo nix-store --optimise

# ---------------------------------------------------------
# Docker
# ---------------------------------------------------------
.PHONY: docker-clean
docker-clean:
	docker system prune -f

.PHONY: docker-nuke
docker-nuke:
	docker system prune -a --volumes -f

# ---------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------
.PHONY: store-size
store-size:
	du -sh /nix/store

.PHONY: store-top
store-top:
	nix path-info -Sh /run/current-system | sort -h | tail -20

.PHONY: diff-last
diff-last:
	nix store diff-closures /run/current-system /nix/var/nix/profiles/system-1-link
