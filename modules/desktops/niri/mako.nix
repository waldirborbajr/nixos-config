# modules/desktops/niri/mako.nix
# Mako notification daemon configuration
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [ mako ];

  xdg.configFile."mako/config".text = ''
    # Appearance
    font=JetBrainsMono Nerd Font 11
    background-color=#1e1e2ef0
    text-color=#cdd6f4
    border-color=#cba6f7
    progress-color=over #45475a
    border-size=2
    border-radius=12
    padding=12
    margin=10
    
    # Behavior
    default-timeout=5000
    ignore-timeout=0
    max-visible=5
    layer=overlay
    anchor=top-right
    
    # Icons
    icons=1
    max-icon-size=48
    icon-path=/run/current-system/sw/share/icons/Papirus-Dark
    
    # Grouping
    group-by=app-name
    
    # Actions
    actions=1
    
    # Format
    format=<b>%s</b>\n%b
    
    # Urgency levels
    [urgency=low]
    border-color=#94e2d5
    default-timeout=3000
    
    [urgency=normal]
    border-color=#cba6f7
    default-timeout=5000
    
    [urgency=critical]
    border-color=#f38ba8
    default-timeout=0
    ignore-timeout=1
    
    # App-specific rules
    [app-name="volume"]
    border-color=#cba6f7
    default-timeout=2000
    group-by=app-name
    
    [app-name="brightness"]
    border-color=#fab387
    default-timeout=2000
    group-by=app-name
    
    [app-name="battery"]
    border-color=#a6e3a1
    default-timeout=10000
  '';
}
