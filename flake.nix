{
  description = "Master Flake for Borba NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # emacs
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Neovim
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # 🔐 secrets management
    sops-nix.url = "github:Mic92/sops-nix";

    # 🏠 home-manager (fase 2)
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🔎 nix-index-database — prebuilt "command not found" DB (all hosts)
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 🎨 treefmt-nix — repo-wide formatter, exposto via `nix fmt`
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    sops-nix,
    home-manager,
    treefmt-nix,
    ...
  } @ inputs: let
    # 🖥️  Hosts NixOS (gerenciam sistema + home-manager embutido)
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

    # 🍎 home-manager standalone (macOS físico) — sem gerenciar o sistema,
    # só pacotes + dotfiles (zsh, git, helix, tmux, wezterm, etc).
    mkMacHome = {
      hostname,
      system ? "aarch64-darwin",
    }:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        extraSpecialArgs = {
          inherit inputs hostname;

          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ./hosts/${hostname}/home.nix
        ];
      };

    # 🧩 Sistemas suportados pelo formatter/treefmt.
    # Inclui aarch64-darwin para o `nix fmt` funcionar também no MacBook M2.
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    # 🌳 Instancia o treefmt para um sistema.
    # A RECURSÃO pelos .nix vem do arquivo ./treefmt.nix — não daqui.
    # Aqui só montamos o wrapper que o `nix fmt` executa.
    treefmtFor = system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      (treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build.wrapper;
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

      mac2011 = mkHost {
        hostname = "mac2011";
        system = "x86_64-linux";
      };
    };

    homeConfigurations = {
      # `home-manager switch --flake .#borba@macbook` no MacBook M2 físico.
      "borba@macbook" = mkMacHome {
        hostname = "macbook";
      };
    };

    # `nix fmt` — mesmo formatter em qualquer host (Linux ou Darwin).
    formatter = nixpkgs.lib.genAttrs supportedSystems treefmtFor;

    # `nix flake check` agora também valida formatação.
    checks = nixpkgs.lib.genAttrs supportedSystems (system: {
      formatting =
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./treefmt.nix).config.build.check;
    });
  };
}
