{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    lua
    lua-language-server
    stylua   # formatter
  ];
}
