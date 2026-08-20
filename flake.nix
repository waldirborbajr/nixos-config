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

    # 🚀 Vicinae — Raycast-like launcher (mac2011 + VMs only, see mac-workstation.nix)
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
