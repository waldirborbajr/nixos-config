{
  description = "MongoDB development environment";

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
        mongodbShell = pkgs.mkShell {
          name = "mongodb-dev";

          buildInputs = with pkgs; [
            mongodb
            mongosh
          ];

          shellHook = ''
            echo "🍃 MongoDB Development Environment"
            echo "mongod: $(mongod --version | head -n 1)"
            echo "mongosh: $(mongosh --version)"
          '';
        };
      in
      {
        devShells = {
          default = mongodbShell;
          mongodb = mongodbShell;
        };
      }
    );
}
