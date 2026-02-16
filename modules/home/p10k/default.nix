{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.apps.zsh.enable {
    # Note: powerlevel10k theme is configured in modules/home/zsh/zsh.nix
    # This module provides optional custom p10k configuration file
    # Uncomment the line below if you have a custom .p10k.zsh file
    # home.file.".p10k.zsh" = {
    #   source = ./.p10k.zsh;
    #   force = true;
    # };
  };
}
