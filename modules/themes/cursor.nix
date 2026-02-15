# modules/themes/cursor.nix
# Cursor theme configuration for Wayland and X11
{
  config,
  pkgs,
  lib,
  options,
  ...
}:

let
  isHomeManager = options ? home;
  cfg = config.theme.cursor;
in
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

  # Only configure home-manager options when in home-manager context
  config = lib.mkMerge [
    (lib.mkIf (isHomeManager && cfg.enable) {
      home.packages = [ cfg.package ];

      home.pointerCursor = {
        package = cfg.package;
        name = cfg.name;
        size = cfg.size;
        gtk.enable = true;
        x11.enable = true;
      };

      # Wayland environment variable
      home.sessionVariables = {
        XCURSOR_THEME = cfg.name;
        XCURSOR_SIZE = toString cfg.size;
      };
    })
  ];
}
