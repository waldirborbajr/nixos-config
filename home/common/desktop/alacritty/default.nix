# { pkgs, ... }:

# {
#   programs.alacritty = {
#     enable = true;

#     settings = {
#       general.live_config_reload = true;

#       terminal.shell = {
#         program = "${pkgs.zsh}/bin/zsh";
#         args = [
#           "-l"
#           "-c"
#           "tmux attach || tmux"
#         ];
#       };

#       env.TERM = "xterm-256color";

#       window = {
#         decorations =
#           if pkgs.stdenv.isDarwin then "buttonless" else "full";

#         dynamic_title = false;
#         dynamic_padding = true;

#         dimensions = {
#           columns = 170;
#           lines = 45;
#         };

#         padding = {
#           x = 5;
#           y = 1;
#         };
#       };

#       scrolling = {
#         history = 10000;
#         multiplier = 3;
#       };

#       keyboard.bindings =
#         if pkgs.stdenv.isDarwin then
#           [
#             {
#               key = "Slash";
#               mods = "Control";
#               chars = ''\u001f'';
#             }
#           ]
#         else
#           [ ];

#       font = {
#         size = if pkgs.stdenv.isDarwin then 15 else 12;

#         normal = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Regular";
#         };

#         bold = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Bold";
#         };

#         italic = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Italic";
#         };

#         bold_italic = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Italic";
#         };
#       };

#       selection = {
#         semantic_escape_chars = '' ,│`|:"' ()[]{}<> '';
#         save_to_clipboard = true;
#       };
#     };
#   };

#   # Tema Catppuccin (global)
#   catppuccin.alacritty.enable = true;
# }

# -- BAIXA PERFORMANCE

# { pkgs, ... }:

# {
#   programs.alacritty = {
#     enable = true;

#     settings = {
#       ####################
#       # Geral
#       ####################
#       general = {
#         live_config_reload = true;
#       };

#       ####################
#       # Ambiente
#       ####################
#       env = {
#         TERM = "xterm-256color";
#       };

#       ####################
#       # Shell / tmux
#       ####################
#       terminal.shell = {
#         program = "${pkgs.zsh}/bin/zsh";
#         args = [
#           "-l"
#           "-c"
#           # Portável e resiliente (Linux / macOS)
#           "tmux new-session -A -D -s DevOps"
#         ];
#       };

#       ####################
#       # Janela
#       ####################
#       window = {
#         decorations =
#           if pkgs.stdenv.isDarwin then "None" else "Full";

#         opacity = 0.90;
#         blur = pkgs.stdenv.isDarwin; # só onde faz sentido
#         dynamic_title = true;
#         dynamic_padding = true;
#         resize_increments = true;
#         startup_mode = "Fullscreen";

#         padding = {
#           x = 10;
#           y = 10;
#         };
#       };

#       ####################
#       # Fonte
#       ####################
#       font = {
#         size = if pkgs.stdenv.isDarwin then 13 else 11;

#         normal = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Regular";
#         };

#         bold = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Bold";
#         };

#         italic = {
#           family = "JetBrainsMono Nerd Font";
#           style = "Italic";
#         };

#         builtin_box_drawing = true;

#         offset = {
#           x = 0;
#           y = 1;
#         };

#         glyph_offset = {
#           x = 0;
#           y = 1;
#         };
#       };

#       ####################
#       # Cursor
#       ####################
#       cursor = {
#         style = {
#           shape = "Beam";
#           blinking = "On";
#         };

#         vi_mode_style = {
#           shape = "Block";
#         };

#         unfocused_hollow = true;
#         thickness = 0.15;
#         blink_interval = 750;
#       };

#       ####################
#       # Scrolling
#       ####################
#       scrolling = {
#         history = 15000;
#         multiplier = 3;
#       };

#       ####################
#       # Seleção
#       ####################
#       selection = {
#         save_to_clipboard = true;
#         semantic_escape_chars = '' ,│`|:"' ()[]{}<> '';
#       };

#       ####################
#       # Teclado
#       ####################
#       keyboard.bindings = [
#         # Clipboard
#         { key = "C"; mods = "Control|Shift"; action = "Copy"; }
#         { key = "V"; mods = "Control|Shift"; action = "Paste"; }
#         { key = "Insert"; mods = "Shift"; action = "PasteSelection"; }

#         # Fonte
#         { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
#         { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
#         { key = "Plus"; mods = "Control"; action = "IncreaseFontSize"; }
#         { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }

#         # Fullscreen
#         { key = "F11"; action = "ToggleFullscreen"; }

#         # Limpar tela
#         { key = "L"; mods = "Control"; chars = "\u000c"; }

#         # Scroll manual
#         { key = "K"; mods = "Control|Shift"; action = "ScrollPageUp"; }
#         { key = "J"; mods = "Control|Shift"; action = "ScrollPageDown"; }
#         { key = "Home"; mods = "Shift"; action = "ScrollToTop"; }
#         { key = "End"; mods = "Shift"; action = "ScrollToBottom"; }

#         # tmux — splits
#         { key = "D"; mods = "Command"; chars = "\u0002\""; }
#         { key = "D"; mods = "Command|Shift"; chars = "\u0002%"; }
#         { key = "O"; mods = "Command"; chars = "\u0002o"; }

#         # tmux — swap / rotate
#         { key = "Left";  mods = "Command"; chars = "\u0002{"; }
#         { key = "Right"; mods = "Command"; chars = "\u0002}"; }
#         { key = "Up";    mods = "Command"; chars = "\u0002{"; }
#         { key = "Down";  mods = "Command"; chars = "\u0002}"; }
#       ];
#     };
#   };

#   ####################
#   # 🎨 Catppuccin (via flake)
#   ####################
#   catppuccin.alacritty.enable = true;
# }

# -- MAXIMA PERFORMANCE

{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;

    settings = {
      ####################
      # Geral — PERFORMANCE
      ####################
      general = {
        live_config_reload = false;
      };

      ####################
      # Ambiente
      ####################
      env = {
        TERM = "xterm-256color";
      };

      ####################
      # Shell / tmux
      ####################
      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [
          "-l"
          "-c"
          "tmux new-session -A -D -s DevOps"
        ];
      };

      ####################
      # Janela — PERFORMANCE FIRST
      ####################
      window = {
        decorations =
          if pkgs.stdenv.isDarwin then "None" else "Full";

        opacity = 1.0;         # 🔥 evita custo de composição
        blur = false;
        dynamic_title = false;
        dynamic_padding = false;
        resize_increments = false;
        startup_mode = "Fullscreen";

        padding = {
          x = 8;
          y = 8;
        };
      };

      ####################
      # Fonte — RENDER OTIMIZADO
      ####################
      font = {
        size = if pkgs.stdenv.isDarwin then 13 else 11;

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

        builtin_box_drawing = true;

        offset = {
          x = 0;
          y = 1;
        };

        glyph_offset = {
          x = 0;
          y = 1;
        };
      };

      ####################
      # Cursor — LEVE
      ####################
      cursor = {
        style = {
          shape = "Beam";
          blinking = "Off";   # 🔥 menos redraw
        };

        vi_mode_style = {
          shape = "Block";
        };

        unfocused_hollow = true;
        thickness = 0.15;
      };

      ####################
      # Scrolling — CONTROLADO
      ####################
      scrolling = {
        history = 10000;
        multiplier = 2;
      };

      ####################
      # Seleção
      ####################
      selection = {
        save_to_clipboard = true;
        semantic_escape_chars = '' ,│`|:"' ()[]{}<> '';
      };

      ####################
      # Teclado
      ####################
      keyboard.bindings = [
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }

        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }

        { key = "F11"; action = "ToggleFullscreen"; }

        { key = "L"; mods = "Control"; chars = "\u000c"; }

        # tmux
        { key = "D"; mods = "Command"; chars = "\u0002\""; }
        { key = "D"; mods = "Command|Shift"; chars = "\u0002%"; }
        { key = "O"; mods = "Command"; chars = "\u0002o"; }
      ];

      ####################
      # Debug — DESLIGADO
      ####################
      debug = {
        render_timer = false;
        persistent_logging = false;
      };
    };
  };

  ####################
  # Tema
  ####################
  catppuccin.alacritty.enable = true;
}
