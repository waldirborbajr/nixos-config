# profiles/developer.nix
# Developer profile - desktop + development tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./desktop.nix
    ../modules/core/virtualization
  ];

  # Enable virtualization and containers by default
  # Can be overridden per-host
}
