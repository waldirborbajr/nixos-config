{ pkgs, ... }:

{
  imports = [
    ./alacritty/default.nix
    ./anydesk/default.nix
    ./browsers/default.nix
    ./telegram/default.nix
    ./wayland/default.nxi
    ./obsidian/default.nix
  ];

}

