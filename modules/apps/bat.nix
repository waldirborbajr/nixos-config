# modules/apps/bat.nix
# bat - cat(1) clone with syntax highlighting and Git integration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.bat.enable {
    programs.bat = {
      enable = true;
      config = {
        pager = "less -FR";
        # Theme is managed by catppuccin module
      };
      extraPackages = with pkgs.bat-extras; [
        batman # man pages with bat
        batpipe # batpipe for various file types
        # batgrep # uncomment if needed
        # batdiff # uncomment if needed
      ];
    };
  };
}
