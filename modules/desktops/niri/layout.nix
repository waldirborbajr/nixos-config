# modules/desktops/niri/layout.nix
# Layout configuration (gaps, borders, focus-ring, cursor, etc)
{ config, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  
  # Catppuccin Mocha colors
  cat = {
    mauve = "cba6f7";
    surface1 = "45475a";
  };
  hex = c: "#${c}";
  
  layoutConfig = ''
    // ============================================
    // LAYOUT CONFIGURATION
    // ============================================
    layout {
      gaps 8
      center-focused-column "on-overflow"
      
      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.5; }
      
      focus-ring {
        width 2
        active-color "${hex cat.mauve}"
        inactive-color "${hex cat.surface1}"
      }

      border {
        off
      }

      struts {
        left 0
        right 0
        top 0
        bottom 0
      }
    }

    // ============================================
    // CURSOR CONFIGURATION
    // ============================================
    cursor {
      xcursor-theme "Adwaita"
      xcursor-size 24
    }

    // ============================================
    // PREFER NO CSD (use SSD)
    // ============================================
    prefer-no-csd

    // ============================================
    // SCREENSHOT PATH
    // ============================================
    screenshot-path "~/Pictures/Screenshots/Screenshot_%Y-%m-%d_%H-%M-%S.png"

    // ============================================
    // HOTKEY OVERLAY
    // ============================================
    hotkey-overlay {
      skip-at-startup
    }

    // ============================================
    // ENVIRONMENT VARIABLES
    // ============================================
    environment {
      DISPLAY null
      QT_QPA_PLATFORM "wayland"
      MOZ_ENABLE_WAYLAND "1"
      NIXOS_OZONE_WL "1"
    }

    // ============================================
    // STARTUP APPLICATIONS
    // ============================================
    spawn-at-startup "mako"
    spawn-at-startup "waybar"
    spawn-at-startup "wl-paste" "--watch" "cliphist" "store"
  '';
in
lib.mkIf isMacbook {
  xdg.configFile."niri/config.d/layout.kdl".text = layoutConfig;
}
