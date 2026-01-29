# modules/languages/default.nix
# Programming language environments with individual enable options (Home Manager level)
{ config, lib, ... }:

{
  imports = [
    ./go.nix
    ./rust.nix
    ./lua.nix
    ./nix-dev.nix
    # Note: Python and Node.js are system-level modules, not home-manager level
  ];

  options.languages = {
    go = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Go development environment";
      };
    };

    rust = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Rust development environment";
      };
    };

    lua = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Lua development environment";
      };
    };

    nix-dev = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Nix development tools";
      };
    };
  };
}
