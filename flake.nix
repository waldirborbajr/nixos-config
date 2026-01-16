# {
#   description = "BORBA JR W | NixOS + Home Manager (Multi-host / Multi-user)";

#   inputs = {
#     nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
#     nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
#     home-manager = {
#       url = "github:nix-community/home-manager";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#     hardware.url = "github:nixos/nixos-hardware";
#     catppuccin.url = "github:catppuccin/nix";

#     # Adicionado: rust-overlay para versões atualizadas e rust-bin
#     rust-overlay = {
#       url = "github:oxalica/rust-overlay";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#   };

#   outputs = {
#     self,
#     nixpkgs,
#     nixpkgs-stable,
#     home-manager,
#     catppuccin,
#     rust-overlay,  # ← novo input aqui
#     ...
#   }@inputs:
#   let
#     system = "x86_64-linux";
#     pkgs-stable = import nixpkgs-stable { inherit system; };

#     # 🔹 Dados de usuários (NÃO é módulo)
#     userConfigs = import ./common/users-data.nix;

#     mkHost = hostname:
#       nixpkgs.lib.nixosSystem {
#         inherit system;
#         specialArgs = {
#           inherit inputs pkgs-stable userConfigs;
#         };
#         modules = [
#           ./common/configuration.nix
#           ./common/packages.nix
#           ./common/programs.nix
#           ./common/fonts.nix
#           # 👇 cria usuários no sistema
#           ./common/users.nix
#           ./hosts/${hostname}
#           home-manager.nixosModules.home-manager
#           catppuccin.nixosModules.catppuccin

#           # ── Bloco com overlay global + config do home-manager ───────────────
#           {
#             # Aplica o rust-overlay em todo o sistema (inclui Home-Manager via useGlobalPkgs)
#             nixpkgs.overlays = [
#               rust-overlay.overlays.default
#             ];

#             home-manager = {
#               useGlobalPkgs = true;
#               useUserPackages = true;
#               # ✅ API NOVA
#               sharedModules = [
#                 catppuccin.homeModules.catppuccin
#               ];
#               users = {
#                 borba = import ./home/borba;
#                 devops = import ./home/devops;
#               };
#               extraSpecialArgs = {
#                 inherit userConfigs;
#               };
#             };
#           }
#         ];
#       };
#   in {
#     nixosConfigurations = {
#       dell = mkHost "dell";
#       macbook = mkHost "macbook";
#       ci = mkNixos "ci" [];
#     };
#   };
# }

{
  description = "BORBA JR W | NixOS + Home Manager (Multi-host / Multi-user)";

  ############################################################
  # Inputs
  ############################################################
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware profiles
    hardware.url = "github:nixos/nixos-hardware";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    # Rust overlay (rust-bin, nightly, etc.)
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  ############################################################
  # Outputs
  ############################################################
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-stable,
      home-manager,
      catppuccin,
      rust-overlay,
      ...
    } @ inputs:
    let
      ##########################################################
      # System
      ##########################################################
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-stable = import nixpkgs-stable { inherit system; };

      ##########################################################
      # User data (não é módulo!)
      ##########################################################
      userConfigs = import ./common/users-data.nix;

      ##########################################################
      # Host factory
      ##########################################################
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit inputs pkgs-stable userConfigs;
          };

          modules = [
            # Base system
            ./common/configuration.nix
            ./common/packages.nix
            ./common/programs.nix
            ./common/fonts.nix
            ./common/users.nix

            # Host-specific
            ./hosts/${hostname}

            # Home Manager
            home-manager.nixosModules.home-manager
            catppuccin.nixosModules.catppuccin

            # Global overlays + HM config
            {
              nixpkgs.overlays = [
                rust-overlay.overlays.default
              ];

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;

                # Home-Manager modules compartilhados
                sharedModules = [
                  catppuccin.homeModules.catppuccin
                ];

                users = {
                  borba = import ./home/borba;
                  devops = import ./home/devops;
                };

                extraSpecialArgs = {
                  inherit userConfigs;
                };
              };
            }
          ];
        };
    in
    {
      ##########################################################
      # NixOS configurations (hosts)
      ##########################################################
      nixosConfigurations = {
        dell = mkHost "dell";
        macbook = mkHost "macbook";

        # Host virtual / headless (CI)
        ci = mkHost "ci";
      };

      ##########################################################
      # Formatter oficial do flake
      #
      # Comando:
      #   nix fmt
      ##########################################################
      formatter.${system} = pkgs.alejandra;

      ##########################################################
      # Flake checks
      #
      # Comando:
      #   nix flake check
      ##########################################################
      checks.${system} = {
        ########################################################
        # Formatting check (alejandra)
        ########################################################
        formatting =
          pkgs.runCommand "alejandra-check" { } ''
            ${pkgs.alejandra}/bin/alejandra --check ${self}
            touch $out
          '';

        ########################################################
        # Lint (statix)
        ########################################################
        lint =
          pkgs.runCommand "statix-check" { } ''
            ${pkgs.statix}/bin/statix check ${self}
            touch $out
          '';
      };
    };
}
