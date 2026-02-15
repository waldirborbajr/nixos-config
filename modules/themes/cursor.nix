# modules/themes/cursor.nix
# Cursor theme options - configuration is applied in home-manager context
{
  pkgs,
  lib,
  ...
}:

{
  options.theme.cursor = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable cursor theme configuration";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.bibata-cursors;
      description = "Cursor theme package to use";
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Ice";
      description = "Cursor theme name";
    };

    size = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size in pixels";
    };
  };

  # Note: This module only defines options.
  # Actual home-manager configuration is applied in home.nix
}
