# profiles/desktop.nix
# Desktop profile - minimal + GUI environment
{ config, pkgs, lib, ... }:

{
  imports = [
    ./minimal.nix
    ../modules/xdg-portal.nix
  ];

  # Desktop capabilities available
  # Actual desktop is selected per-host
}
