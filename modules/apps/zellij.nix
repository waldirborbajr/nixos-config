# modules/apps/zellij.nix
# Zellij terminal multiplexer (alternative to tmux)
{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.apps.zellij.enable {
    home.packages = with pkgs; [
      zellij
    ];
  };
}
