# modules/apps/wezterm.nix
# WezTerm terminal emulator (backup/reserve option)
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.wezterm.enable {
    # ========================================
    # WezTerm (Home Manager)
    # ========================================
    home.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    programs.wezterm = {
      enable = true;

      extraConfig = ''
        local wezterm = require("wezterm")
        
        return {
          font = wezterm.font("JetBrains Mono"),
          font_size = 18.0,
          enable_tab_bar = false,
          window_decorations = "RESIZE",
          color_scheme = "Catppuccin Mocha",
          window_close_confirmation = "NeverPrompt",
          keys = {
            {
              key = "w",
              mods = "SUPER",
              action = wezterm.action.CloseCurrentTab({ confirm = false }),
            },
          },
        }
      '';
    };
  };
}
