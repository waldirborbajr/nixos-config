# =========================================================
# NixOS Maintenance Makefile
# Repo-based (no /etc/nixos, no flakes, no Home Manager)
#
# Philosophy:
# - Configuration lives in a Git repo
# - System is built from where files are, not from /etc/nixos
# - Safe defaults, explicit commands, zero magic
# =========================================================

# Absolute path to the NixOS config repository
CONFIG_DIR ?= $(HOME)/nixos-config

# ---------------------------------------------------------
# Phony targets
# ---------------------------------------------------------
.PHONY: help \
        build switch rollback \
        channels \
        gc-soft gc-hard optimise verify \
        eval build-check ci \
        generations space doctor

# ---------------------------------------------------------
# Help
# ---------------------------------------------------------
help:
	@echo ""
	@echo "NixOS Maintenance Makefile"
	@echo ""
	@echo "Build / Switch:"
	@echo "  make build         - Build system only (no switch)"
	@echo "  make switch        - Build and activate system"
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
	@echo "Validation / CI:"
	@echo "  make eval          - Evaluate NixOS configuration"
	@echo "  make build-check   - Dry build (no activation)"
	@echo "  make ci            - Full local CI (fmt, lint, eval, build)"
	@echo ""
	@echo "Diagnostics:"
	@echo "  make generations   - List system generations"
	@echo "  make space         - Disk usage overview"
	@echo "  make doctor        - System health overview"
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
# Validation / CI (local mirror of GitHub Actions)
# ---------------------------------------------------------
eval:
	@echo ">> Evaluating NixOS configuration..."
	nix-instantiate \
		'<nixpkgs/nixos>' \
		-A system \
		-I nixos-config=$(CONFIG_DIR)/configuration.nix \
		>/dev/null
	@echo "✔ Evaluation successful"

build-check:
	@echo ">> Dry building system (no switch)..."
	sudo nixos-rebuild build \
		-I nixos-config=$(CONFIG_DIR) \
		--dry-run
	@echo "✔ Build check successful"

ci:
	@echo ">> Running full local CI pipeline..."
	@echo ">> Formatting check"
	nix-shell -p nixfmt-rfc-style --run "nixfmt --check $(shell find . -name '*.nix')"
	@echo ">> Static analysis"
	nix-shell -p statix deadnix --run "statix check && deadnix"
	@echo ">> Evaluation"
	$(MAKE) eval
	@echo ">> Build check"
	$(MAKE) build-check
	@echo "✔ CI completed successfully"

# ---------------------------------------------------------
# Diagnostics
# ---------------------------------------------------------
generations:
	sudo nix-env --list-generations \
		--profile /nix/var/nix/profiles/system

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
	readlink /nix/var/nix/profiles/system || true
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
