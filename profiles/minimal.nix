# profiles/minimal.nix
# Basic system profile - only essential system components
{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/system
    ../modules/themes
    ../modules/users/borba.nix
    # System-level languages (always enabled)
    ../modules/languages/python.nix
    ../modules/languages/nodejs.nix
  ];

  # Enable minimal system components
  system-config = {
    base.enable = true;
    networking.enable = true;
    audio.enable = true;
    fonts.enable = true;
    ssh.enable = true;
  };
}
