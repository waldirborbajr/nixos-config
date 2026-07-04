{
  description = "Master Flake for Borba NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @ inputs:
    let
      mkHost = { hostname, system }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs hostname;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            ./configuration.nix
            ./hosts/${hostname}/default.nix      # ← Adicionado
            ./hosts/${hostname}/hardware-configuration.nix
          ];
        };
    in
    {
      nixosConfigurations = {
        dell = mkHost {
          hostname = "dell1456";
          system = "x86_64-linux";
        };

        m2utm = mkHost {
          hostname = "macutm";
          system = "aarch64-linux";
        };

        macbook2011 = mkHost {
          hostname = "mac2011";
          system = "x86_64-linux";
        };
      };
    };
}
