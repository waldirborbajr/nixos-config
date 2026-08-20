{
  description = "Master Flake for Borba NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    #noctalia = {
    #  url = "github:noctalia-dev/noctalia";
    #  inputs.nixpkgs.follows = "nixpkgs"; # this line is optional, prevents downloading two versions of nixpkgs but disables cache
    #};

    # 🔐 secrets management
    sops-nix.url = "github:Mic92/sops-nix";

    # 🏠 home-manager (fase 2)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🚀 Vicinae — Raycast-like launcher (mac2011 + VMs only, see mac-workstation.nix)
    vicinae = {
      url = "github:vicinaehq/vicinae";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🔎 nix-index-database — prebuilt "command not found" DB (all hosts)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🎨 treefmt-nix — repo-wide formatter, exposed via `nix fmt` (all hosts)
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    home-manager,
    ...
  } @ inputs: let
    mkHost = {
      hostname,
      system,
    }:
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
          # 🔐 SOPS module (global)
          sops-nix.nixosModules.sops

          # 🏠 Home Manager (fase 2)
          home-manager.nixosModules.home-manager

          ./configuration.nix
          ./hosts/${hostname}/default.nix # ← macutm ou macvmf, nunca os dois juntos
          ./hosts/${hostname}/hardware-configuration.nix # ← idem
        ];
      };
  in {
    nixosConfigurations = {
      dell = mkHost {
        hostname = "dell1564";
        system = "x86_64-linux";
      };

      m2utm = mkHost {
        hostname = "macutm";
        system = "aarch64-linux";
      };

      macvmf = mkHost {
        hostname = "macvmf";
        system = "aarch64-linux";
      };

      macbook2011 = mkHost {
        hostname = "mac2011";
        system = "x86_64-linux";
      };
    };

    # `nix fmt` — same formatter regardless of which host you're on
    # (dell1564/mac2011 = x86_64-linux, macutm/macvmf = aarch64-linux).
    formatter = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux"] (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        (inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper
    );
  };
}
