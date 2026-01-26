# modules/apps/tmux.nix
#
# tmux — Home Manager managed
# - Config declarativa via programs.tmux
# - Plugins via Nix (incluindo Catppuccin)
# - Integração com tema centralizado

{ config, pkgs, lib, ... }:

{
  ############################################
  # Tmux via Home Manager
  ############################################
  programs.tmux = {
    enable = true;
    
    # Enable Catppuccin theme
    # catppuccin.enable = true;  # FIXME: Module not available in current catppuccin/nix version
    
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    historyLimit = 15000;
    baseIndex = 1;
    
    # Key bindings
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    
    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      resurrect
      continuum
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_window_default_text "#W"
          set -g @catppuccin_window_current_text "#W"
          set -g @catppuccin_status_modules_right "directory session"
          set -g @catppuccin_status_left_separator "█"
          set -g @catppuccin_status_right_separator "█"
        '';
      }
    ];
    
    extraConfig = ''
      #####################################################
      # TERMINAL / APPEARANCE
      #####################################################
      set -as terminal-features ",xterm-256color:RGB"
      set -g focus-events on
      
      #####################################################
      # PREFIX / RELOAD
      #####################################################
      bind C-a send-prefix
      bind r source-file ''$HOME/.config/tmux/tmux.conf \; display-message "󰑓 tmux reloaded"

      #####################################################
      # INDEXES / WINDOWS
      #####################################################
      set -g pane-base-index 1
      set -g renumber-windows on

      #####################################################
      # GENERAL BEHAVIOR
      #####################################################
      set -g repeat-time 600
      set -g status-position bottom
      set -g status-interval 5
      set -g display-time 800

      #####################################################
      # SMART WINDOW NAMES (DEVOPS FRIENDLY)
      #####################################################
      setw -g automatic-rename on
      set -g automatic-rename-format '#{pane_current_command}'

      #####################################################
      # PANE NAVIGATION (VIM STYLE)
      #####################################################
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # No-prefix navigation (turbo mode)
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      #####################################################
      # RESIZE PANES
      #####################################################
      bind -r Left  resize-pane -L 5
      bind -r Right resize-pane -R 5
      bind -r Up    resize-pane -U 3
      bind -r Down  resize-pane -D 3

      # Vim-style resize
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 3
      bind -r K resize-pane -U 3
      bind -r L resize-pane -R 5

      #####################################################
      # SPLITS / WINDOWS (PATH AWARE)
      #####################################################
      unbind %
      unbind '"'

      bind | split-window -h -c "#{pane_current_path}"
      bind _ split-window -v -c "#{pane_current_path}"

      bind c new-window -c "#{pane_current_path}"
      bind m resize-pane -Z

      #####################################################
      # WINDOW SWITCHING
      #####################################################
      bind -n S-Left  previous-window
      bind -n S-Right next-window
      bind -n M-H previous-window
      bind -n M-L next-window

      #####################################################
      # COPY MODE (VI)
      #####################################################
      bind -T copy-mode-vi v     send -X begin-selection
      bind -T copy-mode-vi C-v   send -X rectangle-toggle
      bind -T copy-mode-vi y     send -X copy-selection-and-cancel
      bind -T copy-mode-vi Enter send -X copy-selection-and-cancel

      #####################################################
      # SESSION PERSISTENCE (DEVOPS GOLD)
      #####################################################
      set -g @resurrect-capture-pane-contents 'on'
      set -g @resurrect-strategy-nvim 'session'
      set -g @resurrect-strategy-vim 'session'
      set -g @resurrect-processes 'ssh kubectl helm terraform nvim vim'

      set -g @continuum-restore 'on'
      set -g @continuum-save-interval '10'
    '';
  };
}