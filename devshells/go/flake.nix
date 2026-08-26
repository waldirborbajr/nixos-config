{
  description = "Go development environment";

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
        goShell = pkgs.mkShell {
          name = "go-dev";

          buildInputs = with pkgs; [
            go_1_25
            gopls
            delve
            gotools
            gofumpt
            golangci-lint
            golangci-lint-langserver # wrapper LSP, equivalente ao que existia no sistema
            go-task
            air
          ];

          shellHook = ''
            export GOPATH="$HOME/go"
            export GOBIN="$GOPATH/bin"
            export PATH="$GOBIN:$PATH"
            echo "🐹 Go Development Environment"
            echo "Go version: $(go version)"
            echo ""
            echo "Available tools:"
            echo "  - gopls, delve, gofumpt, golangci-lint"
            echo "  - go-task (task runner), air (hot reload)"
          '';
        };
      in
      {
        devShells = {
          default = goShell;
          go = goShell;
        };
      }
    );
}
