# modules/apps/fzf.nix
# fzf - Command-line fuzzy finder
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.fzf.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;

      # Theme is managed by catppuccin module
      
      defaultCommand = "fd --type f --hidden --follow --exclude .git || find . -type f";
      
      defaultOptions = [
        "--height 60%"
        "--layout=reverse"
        "--border=rounded"
        "--info=inline-right"
        "--ansi"
      ];

      # File finder options
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git || find . -type f";
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];

      # Directory finder options
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git || find . -type d";
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];
    };
  };
}
