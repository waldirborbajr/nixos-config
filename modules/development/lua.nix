{
  config,
  lib,
  pkgs,
  ...
}:

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
