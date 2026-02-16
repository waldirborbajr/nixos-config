# modules/home/languages/default.nix
# Home-manager configurations for programming languages
# This module imports the core language configurations
{ config, lib, ... }:

{
  # Import the complete language module from core
  # It defines all options and implementations for:
  # - go, rust, lua, nix-dev (full packages + configs)
  # - python, nodejs (home-manager aliases/configs, system packages in profiles)
  imports = [
    ../../core/languages/default.nix
  ];
}
