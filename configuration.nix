# configuration.nix
{ config, pkgs, lib, ... }:

{
  ############################################
  # Host-specific configurations
  ############################################
  imports = [
    ./hosts/macbook.nix
    # ./hosts/dell.nix

    ############################################
    # Core system modules
    ############################################
    ./core.nix
  ];

  ############################################
  # NixOS version compatibility
  ############################################
  system.stateVersion = "25.11";
}
