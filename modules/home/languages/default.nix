# modules/home/languages/default.nix
# Home-manager configurations for programming languages
{ config, lib, ... }:

{
  imports = [
    ./nodejs.nix
    ./python.nix
  ];

  # Define language options for home-manager
  options.languages = {
    # System-level toolchains (home-manager configs: aliases, environment variables, etc.)
    python = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Python home-manager configuration (aliases, environment variables)";
      };
    };

    nodejs = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Node.js home-manager configuration (aliases, environment variables)";
      };
    };

    # Optional language support (can be enabled individually)
    go = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Go programming language support";
      };
    };

    rust = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Rust programming language support";
      };
    };

    lua = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Lua programming language support";
      };
    };

    nix-dev = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Nix development tools";
      };
    };
  };

  # Note: System-level language packages are in modules/core/languages/
  # This folder contains only home-manager configurations (aliases, environment variables, etc.)
}
