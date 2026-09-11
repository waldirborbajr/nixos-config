{ config, lib, pkgs, ... }:
{
  imports = [
    ./base.nix
    ./go.nix
    ./python.nix
    ./rust.nix
    ./lua.nix
    ./nix.nix
    ./arduino.nix
    ./latex.nix
    ./postgres.nix
    ./mariadb.nix
    ./mongodb.nix
    ./ferretdb.nix
    ./sqlite.nix
  ];

  options.development.languages = {
    nix.enable = lib.mkEnableOption "Nix development tooling";
    go.enable = lib.mkEnableOption "Go development tooling";
    python.enable = lib.mkEnableOption "Python development tooling";
    rust.enable = lib.mkEnableOption "Rust development tooling";
    lua.enable = lib.mkEnableOption "Lua development tooling";
  };
}
