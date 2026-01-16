{
  description = "BORBA JR W | NixOS + Home Manager (Multi-host / Multi-user)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    catppuccin.url = "github:catppuccin/nix";

    # Adicionado: rust-overlay para versões atualizadas e rust-bin
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    catppuccin,
    rust-overlay,  # ← novo input aqui
    ...
  }@inputs:
  let
    system = "x86_64-linux";
    pkgs-stable = import nixpkgs-stable { inherit system; };

    # 🔹 Dados de usuários (NÃO é módulo)
    userConfigs = import ./common/users-data.nix;

    mkHost = hostname:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs pkgs-stable userConfigs;
        };
        modules = [
          ./common/configuration.nix
          ./common/packages.nix
          ./common/programs.nix
          ./common/fonts.nix
          # 👇 cria usuários no sistema
          ./common/users.nix
          ./hosts/${hostname}
          home-manager.nixosModules.home-manager
          catppuccin.nixosModules.catppuccin

          # ── Bloco com overlay global + config do home-manager ───────────────
          {
            # Aplica o rust-overlay em todo o sistema (inclui Home-Manager via useGlobalPkgs)
            nixpkgs.overlays = [
              rust-overlay.overlays.default
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              # ✅ API NOVA
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
  in {
    nixosConfigurations = {
      dell = mkHost "dell";
      macbook = mkHost "macbook";
      ci = mkNixos "ci" [];
    };
  };
}
