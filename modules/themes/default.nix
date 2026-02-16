# modules/themes/default.nix
# Centralized theme management
# Switch themes easily by changing flavor here
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./cursor.nix
  ];

  options = {
    theme = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable centralized theme management";
      };

      flavor = lib.mkOption {
        type = lib.types.enum [
          "latte"
          "frappe"
          "macchiato"
          "mocha"
        ];
        default = "mocha";
        description = "Catppuccin flavor to use across the system";
      };

      accent = lib.mkOption {
        type = lib.types.enum [
          "rosewater"
          "flamingo"
          "pink"
          "mauve"
          "red"
          "maroon"
          "peach"
          "yellow"
          "green"
          "teal"
          "sky"
          "sapphire"
          "blue"
          "lavender"
        ];
        default = "blue";
        description = "Accent color for the theme";
      };
    };
  };

  config = lib.mkIf config.theme.enable {
    # ==========================================
    # Catppuccin global configuration - DISABLED at NixOS level
    # Due to GTK module conflict with NixOS 25.11
    # Individual apps can still enable Catppuccin via their own modules
    # ==========================================
    # catppuccin = {
    #   enable = true;
    #   flavor = config.theme.flavor;
    #   accent = config.theme.accent;
    # };

    # ==========================================
    # Export theme colors for custom configs
    # This allows modules to access theme colors
    # ==========================================
    # NOTE: Color values are provided by catppuccin module
    # Access via: config.catppuccin.sources.${flavor}
  };
}
