{ pkgs, ... }:
{
  # Nix language tooling: language servers and formatter.
  # These are intentionally kept out of the global NixOS package set.
  environment.systemPackages = with pkgs; [
    nixd
    nil
    alejandra
  ];
}
