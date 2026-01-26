# modules/apps/terminals.nix
# Consolidado: Alacritty + Kitty with Catppuccin theme
{ config, pkgs, lib, ... }:

{
  # ========================================
  # Alacritty (Home Manager)
  # ========================================
  home.packages = with pkgs; [
    alacritty
    kitty
    nerd-fonts.jetbrains-mono
  ];

  # Enable Catppuccin theme for Alacritty
  programs.alacritty = {
    enable = true;
    catppuccin.enable = true;  # Uses global theme config
    
    settings = {
      env.TERM = "xterm-256color";
      
      window = {
        padding = { x = 8; y = 8; };
        decorations = "None";
        opacity = 1.0;
        blur = false;
        dynamic_title = true;
        resize_increments = true;
        startup_mode = "Fullscreen";
      };

      terminal.shell = {
        program = "${pkgs.zsh}/bin/zsh";
        args = [ "-l" ];
      };

      font = {
        size = 13.0;
        builtin_box_drawing = true;
        normal = { family = "JetBrainsMono Nerd Font"; style = "Regular"; };
        bold = { family = "JetBrainsMono Nerd Font"; style = "Bold"; };
        italic = { family = "JetBrainsMono Nerd Font"; style = "Italic"; };
        offset = { x = 0; y = 1; };
        glyph_offset = { x = 0; y = 0; };
      };

      cursor = {
        unfocused_hollow = true;
        style = "Beam";
        vi_mode_style = "Block";
      };

      scrolling = {
        history = 5000;
        multiplier = 3;
      };

      debug = {
        render_timer = false;
        persistent_logging = false;
        log_level = "Off";
      };
    };
  };

  # Enable Catppuccin theme for Kitty
  programs.kitty = {
    enable = true;
    catppuccin.enable = true;  # Uses global theme config
    
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };

    settings = {
      shell = "${pkgs.zsh}/bin/zsh -l";
      
      # Window settings
      window_padding_width = 8;
      hide_window_decorations = "yes";
      background_opacity = "1.0";
      dynamic_background_opacity = "no";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Cursor
      cursor_shape = "beam";
      cursor_beam_thickness = "1.5";
      cursor_blink_interval = 0;
      
      # Scrollback
      scrollback_lines = 5000;
      
      # Mouse
      mouse_hide_wait = 3.0;
      detect_urls = "yes";
      
      # Advanced
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = 0.0;
    };

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+up" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+page_up" = "scroll_page_up";
      "ctrl+shift+page_down" = "scroll_page_down";
      "ctrl+shift+home" = "scroll_home";
      "ctrl+shift+end" = "scroll_end";
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+equal" = "increase_font_size";
      "ctrl+shift+minus" = "decrease_font_size";
      "ctrl+shift+backspace" = "restore_font_size";
    };
  };
}

