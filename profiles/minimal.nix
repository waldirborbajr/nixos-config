# profiles/minimal.nix
# Basic system profile - only essential system components
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ../modules/core/system
    ../modules/core/users/borba.nix
    # System-level languages (always enabled)
    ../modules/core/languages/python.nix
    ../modules/core/languages/nodejs.nix
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
