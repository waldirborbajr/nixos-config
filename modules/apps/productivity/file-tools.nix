# modules/apps/productivity/file-tools.nix
# Modern file operations and navigation tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.productivity.file-tools.enable {
    home.packages = with pkgs; [
      eza # Modern ls replacement
      fd # Modern find replacement
      dust # Modern du replacement
      ncdu # NCurses disk usage
      tree # Directory tree viewer
    ]
    ++ lib.optional config.apps.productivity.file-tools.superfile.enable superfile
    ++ lib.optional config.apps.productivity.file-tools.nemo.enable nemo;

    # Shell aliases for file tools
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      ls = "eza";
      ll = "eza -lg --icons --group-directories-first";
      la = "eza -lag --icons --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      find = "fd";
      du = "dust";
      df = "dust";
    };
  };

  options.apps.productivity.file-tools = {
    superfile = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable superfile - modern terminal file manager";
      };
    };

    nemo = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Nemo file manager (GUI file manager)";
      };
    };
  };
}
