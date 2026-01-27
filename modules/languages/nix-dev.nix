# modules/languages/nix-dev.nix
# Nix development tools
{ config, pkgs, lib, ... }:

let
  enableNixDev = true;  # true | false
in
{
  # ========================================
  # Nix development packages
  # ========================================
  home.packages = lib.optionals enableNixDev (with pkgs; [
    nixpkgs-fmt      # Formatter (official)
    alejandra        # Alternative formatter (opinionated)
    nil              # Nix LSP
    nixd             # Alternative Nix LSP
    nix-tree         # Visualize derivations
    nix-diff         # Diff derivations
    nix-update       # Update package versions
    nix-init         # Generate nix expressions
    statix           # Linter
    deadnix          # Dead code detection
  ]);

  # ========================================
  # Shell aliases
  # ========================================
  programs.zsh.shellAliases = lib.mkIf (enableNixDev && config.programs.zsh.enable) {
    nxfmt   = "nixpkgs-fmt";
    nxfmta  = "alejandra";
    nxtree  = "nix-tree";
    nxdiff  = "nix-diff";
    nxupd   = "nix-update";
    nxlint  = "statix check";
    nxfix   = "statix fix";
    nxdead  = "deadnix";
    nxbuild = "nix build";
    nxdev   = "nix develop";
    nxshell = "nix-shell";
    nxflake = "nix flake";
  };

  # ========================================
  # Environment variables
  # ========================================
  home.sessionVariables = lib.mkIf enableNixDev {
    NIX_PATH = "nixpkgs=${pkgs.path}";
  };
}
