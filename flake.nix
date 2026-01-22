# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";  # Utiliza flake-utils para suporte a múltiplos sistemas
  };

  outputs = { self, nixpkgs, flake-utils, ... }: flake-utils.lib.eachSystem
    (system: {
      nixosConfigurations = {

        # ==========================================
        # MacBook host
        # ==========================================
        macbook = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./core.nix
            ./hosts/macbook.nix
          ];

          # Systemd-boot configuration (applied only for this host)
          boot.loader.systemd-boot.configurationLimit = 10;
          boot.loader.systemd-boot.enable = true;
          boot.loader.grub.enable = false;  # Desabilitando GRUB para usar systemd-boot
          boot.rollback.enable = true;      # Habilitando o rollback de configurações
        };

        # ==========================================
        # Dell host
        # ==========================================
        dell = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ./core.nix
            ./hosts/dell.nix
          ];

          # Systemd-boot configuration (applied only for this host)
          boot.loader.systemd-boot.configurationLimit = 10;
          boot.loader.systemd-boot.enable = true;
          boot.loader.grub.enable = false;  # Desabilitando GRUB para usar systemd-boot
          boot.rollback.enable = true;      # Habilitando o rollback de configurações
        };
      };
    });
}
