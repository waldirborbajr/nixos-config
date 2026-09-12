{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.lua.enable {
    environment.systemPackages = with pkgs; [
      lua5_4
      luajit
      luarocks
      lua-language-server
      stylua
      selene
    ];
  };
}
