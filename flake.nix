# flake.nix
# NixOS Flake configuration for multiple hosts
{
  description = "NixOS configuration for Dell Inspiron 1564, MacBook Pro 2011, and Mac VMs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # SOPS for secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Vicinae - Launcher (Raycast-like)
    vicinae = {
      url = "github:vicinaehq/vicinae";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Treefmt for code formatting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    vicinae,
    treefmt-nix,
    ...
  } @ inputs: let
    # Utility function to iterate over systems
    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
    ];

    # System configuration function
    mkSystem = {
      system,
      hostname,
      modules ? [],
      specialArgs ? {},
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs =
          {
            inherit inputs;
            inherit hostname;
            inherit (self) outputs;
          }
          // specialArgs;
        modules =
          [
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              # Home Manager configuration
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.borba = import ./home;
                extraSpecialArgs = {
                  inherit inputs;
                  inherit hostname;
                };
              };
            }
            ./configuration.nix
            ./hosts/${hostname}/default.nix
          ]
          ++ modules;
      };

    # Helper to import devshells - each returns a set with 'default' attribute
    mkDevShell = {
      pkgs,
      path,
    }:
      import path {inherit pkgs;};

    mkDevShells = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      go =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/go;
        }).default;
      rust =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/rust;
        }).default;
      lua =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/lua;
        }).default;
      python =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/python;
        }).default;
      arduino =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/arduino;
        }).default;
      latex =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/latex;
        }).default;
      postgresql =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/postgresql;
        }).default;
      mariadb =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/mariadb;
        }).default;
      mongodb =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/mongodb;
        }).default;
      sqlite =
        (mkDevShell {
          inherit pkgs;
          path = ./devshells/sqlite;
        }).default;
    };
  in {
    nixosConfigurations = {
      # Dell Inspiron 1564
      dell1564 = mkSystem {
        system = "x86_64-linux";
        hostname = "dell1564";
      };

      # MacBook Pro 13" (2011)
      mac2011 = mkSystem {
        system = "x86_64-linux";
        hostname = "mac2011";
      };

      # Mac M2 - UTM VM
      macutm = mkSystem {
        system = "aarch64-linux";
        hostname = "macutm";
      };

      # Mac M2 - VMware Fusion VM
      macvmf = mkSystem {
        system = "aarch64-linux";
        hostname = "macvmf";
      };
    };

    # Development shells
    # devShells = forAllSystems (system: mkDevShells system);

    # Formatter configuration
    formatter = forAllSystems (
      system:
        treefmt-nix.lib.${system}.mkFormatter {
          projectRoot = ./.;
          programs = {
            nixpkgs-fmt.enable = true;
            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        }
    );

    # Checks
    checks = forAllSystems (system: {
      format = self.formatter.${system}.check ./.;
    });
  };
}
