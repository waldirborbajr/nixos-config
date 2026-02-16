# modules/system/hm-gtk-compat.nix
# Compatibility fix for Home Manager GTK module with NixOS 25.11
# The Home Manager GTK NixOS module tries to set services.displayManager.generic
# which was removed in newer NixOS versions
{
  config,
  lib,
  ...
}:

{
  # Define the missing option to prevent Home Manager's GTK module from failing
  options.services.displayManager.generic = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    description = "Compatibility option for Home Manager GTK module";
  };
}
