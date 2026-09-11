{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/lua (nix develop).
{
  environment.systemPackages = with pkgs; [
    lua5_4
    luajit
    luarocks
    lua-language-server
    stylua
    selene
  ];
}
