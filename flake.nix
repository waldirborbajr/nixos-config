# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Novo: home-manager (seguindo sua nixpkgs-stable para compatibilidade)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };
  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }:
  let
    lib = nixpkgs-stable.lib;
    # ==========================================
    # Feature flags (require --impure to read env)
    # ==========================================
    devopsEnabled = builtins.getEnv "DEVOPS" == "1";
    qemuEnabled = builtins.getEnv "QEMU" == "1";
    # ==========================================
    # Overlay: exposes pkgs.unstable for the SAME hostPlatform.system
    # Usage inside modules: pkgs.unstable.<pkg>
    # ==========================================
    unstableOverlay = final: prev: {
      unstable = import nixpkgs-unstable {
        inherit (final.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    };
    # Common nixpkgs settings applied to all hosts
    nixpkgsConfig = {
      config.allowUnfree = true;
      overlays = [ unstableOverlay ];
    };
    # ==========================================
    # Host builder (future-proof; per-host system)
    # ==========================================
    mkHost = { hostname, system }:
      lib.nixosSystem {
        # REMOVA ESTA LINHA:
        # hostPlatform.system = system;
        # Mantenha specialArgs
        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled;
        };
        modules = [
          # Aplique o system via módulo (recomendado em 25.11+)
          ({ config, pkgs, lib, ... }: {
            nixpkgs.hostPlatform = system; # <-- Isso define o hostPlatform corretamente
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [ unstableOverlay ];
          })
          ./core.nix
          (./hosts + "/${hostname}.nix")

          # Novo: importa o home-manager como módulo NixOS
          home-manager.nixosModules.home-manager

          # Configuração básica do home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs devopsEnabled qemuEnabled;
            };

            # Defina seu usuário aqui (substitua "waldir" pelo seu username real!)
            home-manager.users.waldir = import ./home.nix;
          }
        ];
      };
     
/*
    mkHost = { hostname, system }:
      lib.nixosSystem {
        # NixOS 25.11+: prefer hostPlatform.system (system is deprecated here)
        hostPlatform.system = system;
        # Pass flags + inputs into modules when needed
        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled;
        };
        modules = [
          # Always apply overlays/unfree globally for this host
          ({ ... }: { nixpkgs = nixpkgsConfig; })
          ./core.nix
          (./hosts + "/${hostname}.nix")
        ];
      };
*/
    # Systems we care about (formatter + future machines)
    supportedSystems = [
      "x86_64-linux" # Intel/AMD PCs, most VMs
      "aarch64-linux" # Apple Silicon, Raspberry Pi (64-bit), ARM VMs
    ];
  in
  {
    # ==========================================
    # Enables: `nix fmt`
    # (nix fmt needs formatter.${system})
    # ==========================================
    formatter = lib.genAttrs supportedSystems (system:
      (import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      }).nixpkgs-fmt
    );
    # ==========================================
    # Hosts
    # ==========================================
    nixosConfigurations = {
      # --------------------------
      # CURRENT (your machines)
      # --------------------------
      macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
      dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
      # =========================================================
      # FUTURE / TEMPLATE HOSTS (commented, ready to enable)
      # =========================================================
      # amd = mkHost { hostname = "amd"; system = "x86_64-linux"; };
      # apple-m = mkHost { hostname = "apple-m"; system = "aarch64-linux"; };
      # raspberry = mkHost { hostname = "raspberry"; system = "aarch64-linux"; };
      # vm-x86 = mkHost { hostname = "vm-x86"; system = "x86_64-linux"; };
      # vm-arm = mkHost { hostname = "vm-arm"; system = "aarch64-linux"; };
    };
  };
}
