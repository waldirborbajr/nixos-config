# modules/desktops/niri/fuzzel.nix
# Fuzzel application launcher configuration
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = hostname == "macbook-nixos" || hostname == "macbook";
  term = "alacritty";
in
lib.mkIf isMacbook {
  home.packages = with pkgs; [ fuzzel ];

  xdg.configFile."fuzzel/fuzzel.ini".text = ''
    [main]
    font=JetBrainsMono Nerd Font:size=12
    dpi-aware=yes
    prompt=" ❯ "
    icon-theme=Papirus-Dark
    icons-enabled=yes
    fields=filename,name,generic
    fuzzy=yes
    show-actions=yes
    terminal=${term}
    
    # Geometry
    width=50
    lines=15
    tabs=4
    horizontal-pad=20
    vertical-pad=12
    inner-pad=8
    
    # Appearance
    line-height=24
    letter-spacing=0
    
    [colors]
    background=#1e1e2ef0
    text=#cdd6f4ff
    match=#cba6f7ff
    selection=#313244ff
    selection-text=#cdd6f4ff
    selection-match=#f5c2e7ff
    border=#cba6f7ff
    
    [border]
    width=2
    radius=12
    
    [dmenu]
    exit-immediately-if-empty=yes
  '';
}
