# modules/apps/nix.nix
# Nix package manager tools and configuration (Home Manager)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.nix.enable {
    # Nix-related packages
    home.packages = with pkgs; [
      nix-output-monitor # Prettier nix build output
      nix-tree # Visualize nix dependencies
      nix-diff # Compare nix derivations
      nvd # Nix version diff tool
      nix-prefetch-git # Pre-fetch git repos
    ];

    # Nix-related shell aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      # Nix commands with prettier output
      nom = "nix-output-monitor";
      nom-build = "nom build";
      nom-shell = "nom shell";
      nom-develop = "nom develop";

      # Nix utilities
      nix-tree = "nix-tree";
      nix-diff = "nix-diff";
      nvd-diff = "nvd diff";

      # Common nix operations
      nix-gc = "nix-collect-garbage -d";
      nix-optimize = "nix-store --optimize";
      nix-repair = "nix-store --verify --check-contents --repair";
    };
  };
}
