# home/modules/alacritty.nix
#
# Alacritty sob controle do Home Manager (programs.alacritty).
# Config comum + overrides por OS (Linux vs Darwin) via hostPlatform —
# sem arquivo os.toml separado nem general.import.
{
  config,
  pkgs,
  ...
}: {
  programs.alacritty = {
    enable = true;

    settings = {
      general = {
        live_config_reload = true;
      };

      env = {
        TERM = "xterm-256color";
      };

      window =
        {
          opacity = 0.975;
          dynamic_title = true;
          dynamic_padding = false;
          resize_increments = true;
          startup_mode = "Windowed";
          dimensions = {
            columns = 118;
            lines = 30;
          };
        }
        // (
          if pkgs.stdenv.hostPlatform.isDarwin
          then {
            padding = {
              x = 8;
              y = 8;
            };
            decorations = "Buttonless";
            option_as_alt = "OnlyLeft";
          }
          else {
            padding = {
              x = 6;
              y = 6;
            };
            decorations = "None";
          }
        );

      font = {
        builtin_box_drawing = true;
        normal = {
          family = "JetBrainsMono Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "JetBrainsMono Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "JetBrainsMono Nerd Font";
          style = "Italic";
        };
        offset = {
          x = 0;
          y = 1;
        };
        glyph_offset = {
          x = 0;
          y = 0;
        };
        size =
          if pkgs.stdenv.hostPlatform.isDarwin
          then 14.0
          else 9.0;
      };

      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
        blink_interval = 750;
        unfocused_hollow = true;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      # Cores vindas da paleta base16 central (home/modules/theme.nix).
      # Dim (variantes escuras) não existem no base16 e ficam literais.
      colors = {
        primary = {
          background = "#${config.colorScheme.palette.base00}";
          foreground = "#${config.colorScheme.palette.base04}";
          dim_foreground = "#a5abb6";
        };
        cursor = {
          text = "#${config.colorScheme.palette.base00}";
          cursor = "#${config.colorScheme.palette.base04}";
        };
        vi_mode_cursor = {
          text = "#${config.colorScheme.palette.base00}";
          cursor = "#${config.colorScheme.palette.base04}";
        };
        selection = {
          text = "CellForeground";
          background = "#${config.colorScheme.palette.base03}";
        };
        search = {
          matches = {
            foreground = "CellBackground";
            background = "#${config.colorScheme.palette.base0C}";
          };
        };
        footer_bar = {
          background = "#${config.colorScheme.palette.base02}";
          foreground = "#${config.colorScheme.palette.base04}";
        };
        normal = {
          black = "#${config.colorScheme.palette.base01}";
          red = "#${config.colorScheme.palette.base08}";
          green = "#${config.colorScheme.palette.base0B}";
          yellow = "#${config.colorScheme.palette.base0A}";
          blue = "#${config.colorScheme.palette.base0D}";
          magenta = "#${config.colorScheme.palette.base0E}";
          cyan = "#${config.colorScheme.palette.base0C}";
          white = "#${config.colorScheme.palette.base05}";
        };
        bright = {
          black = "#${config.colorScheme.palette.base03}";
          red = "#${config.colorScheme.palette.base08}";
          green = "#${config.colorScheme.palette.base0B}";
          yellow = "#${config.colorScheme.palette.base0A}";
          blue = "#${config.colorScheme.palette.base0D}";
          magenta = "#${config.colorScheme.palette.base0E}";
          cyan = "#${config.colorScheme.palette.base07}";
          white = "#${config.colorScheme.palette.base06}";
        };
        dim = {
          black = "#373e4d";
          red = "#94545d";
          green = "#809575";
          yellow = "#b29e75";
          blue = "#68809a";
          magenta = "#8c738c";
          cyan = "#6d96a5";
          white = "#aeb3bb";
        };
      };

      bell = {
        animation = "Linear";
        duration = 0;
      };

      selection = {
        # Sem " nem \ — o serializador TOML do HM quebra escapes complexos
        # (default do Alacritty já cobre o essencial).
        semantic_escape_chars = ",│`|:' ()[]{}<>‖";
      };

      # OSC52 para clipboard do tmux; URL auto-open desabilitado (security)
      terminal = {
        osc52 = "CopyPaste";
        shell = {
          program = "zsh";
          args = ["-l"];
        };
      };

      mouse = {
        hide_when_typing = false;
      };

      # Hints: URLs só via atalho de teclado (Copy), não click
      hints = {
        enabled = [
          {
            regex = "(ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|ssh:|git://)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩]+";
            action = "Copy";
            post_processing = true;
            mouse = {
              enabled = false;
            };
            binding = {
              key = "U";
              mods = "Control|Shift";
            };
          }
        ];
      };

      keyboard = {
        bindings = [
          {
            key = "C";
            mods = "Control|Shift";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Control|Shift";
            action = "Paste";
          }
          {
            key = "N";
            mods = "Control|Shift";
            action = "CreateNewWindow";
          }
          {
            key = "=";
            mods = "Control";
            action = "IncreaseFontSize";
          }
          {
            key = "+";
            mods = "Control";
            action = "IncreaseFontSize";
          }
          {
            key = "-";
            mods = "Control";
            action = "DecreaseFontSize";
          }
          {
            key = "0";
            mods = "Control";
            action = "ResetFontSize";
          }
          {
            key = "F11";
            mods = "None";
            action = "ToggleFullscreen";
          }
          {
            key = "F";
            mods = "Control|Shift";
            action = "ToggleFullscreen";
          }
          {
            key = "PageUp";
            mods = "Shift";
            action = "ScrollPageUp";
          }
          {
            key = "PageDown";
            mods = "Shift";
            action = "ScrollPageDown";
          }
          {
            key = "Home";
            mods = "Shift";
            action = "ScrollToTop";
          }
          {
            key = "End";
            mods = "Shift";
            action = "ScrollToBottom";
          }
          {
            key = "L";
            mods = "Control";
            chars = builtins.fromJSON "\"\\f\""; # Nix não tem \f: fromJSON gera form feed (0x0C)
          }
          {
            key = "K";
            mods = "Control";
            action = "ClearHistory";
          }
        ];
      };

      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "Off";
        print_events = false;
      };
    };
  };
}
