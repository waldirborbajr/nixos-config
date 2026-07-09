{
  description = "Lua development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        luaShell = pkgs.mkShell {
          name = "lua-dev";

          buildInputs = with pkgs; [
            lua5_4
            luajit
            luarocks
            lua-language-server
            stylua
            selene
          ];

          shellHook = ''
            export LUA_PATH="$HOME/.luarocks/share/lua/5.4/?.lua;$HOME/.luarocks/share/lua/5.4/?/init.lua;;"
            export LUA_CPATH="$HOME/.luarocks/lib/lua/5.4/?.so;;"
            echo "🌙 Lua Development Environment"
            echo "Lua: $(lua5.4 -v)"
            echo "LuaJIT: $(luajit -v)"
            echo ""
            echo "Available tools:"
            echo "  - lua-language-server (LSP)"
            echo "  - stylua (formatter)"
            echo "  - selene (linter)"
            echo "  - luarocks (package manager)"
          '';
        };
      in
      {
        devShells = {
          default = luaShell;
          lua = luaShell;
        };
      }
    );
}
