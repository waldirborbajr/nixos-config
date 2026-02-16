# modules/home/languages/default.nix
# Home-manager configurations for programming languages
{ config, lib, ... }:

{
  imports = [
    ./nodejs.nix
    ./python.nix
  ];

  # Note: System-level language packages are in modules/core/languages/
  # This folder contains only home-manager configurations (aliases, environment variables, etc.)
}
