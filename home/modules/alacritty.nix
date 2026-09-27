# home/modules/alacritty.nix
#
# Alacritty sob controle do Home Manager (programs.alacritty).
# Config comum + overrides por OS (Linux vs Darwin) via hostPlatform —
# sem arquivo os.toml separado nem general.import.
{pkgs, ...}: {
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

      # Nord (nordtheme/alacritty, official palette)
      # https://github.com/nordtheme/alacritty
      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
          dim_foreground = "#a5abb6";
        };
        cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        vi_mode_cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        selection = {
          text = "CellForeground";
          background = "#4c566a";
        };
        search = {
          matches = {
            foreground = "CellBackground";
            background = "#88c0d0";
          };
        };
        footer_bar = {
          background = "#434c5e";
          foreground = "#d8dee9";
        };
        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };
        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
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
        semantic_escape_chars = ",│`|:\"' ()[]{}<>\\‖";
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
            chars = "\f";
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
