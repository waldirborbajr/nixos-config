# flake.nix
# ---
{
  description = "BORBA JR W - Multi-host NixOS Flake";
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager (seguindo nixpkgs-stable para compatibilidade)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # Theme: Catppuccin (centralizado)
    catppuccin.url = "github:catppuccin/nix";

    # DevShells: Rust toolchains via fenix
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # DevShells: Helper para múltiplos sistemas
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, catppuccin, fenix, flake-utils, ... }:
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
        specialArgs = {
          inherit inputs devopsEnabled qemuEnabled hostname; # ← adicionado hostname aqui
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

          # Theme: Catppuccin NixOS module
          catppuccin.nixosModules.catppuccin

          # Novo: importa o home-manager como módulo NixOS
          home-manager.nixosModules.home-manager

          # Configuração básica do home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              inherit inputs devopsEnabled qemuEnabled hostname; # ← adicionado hostname aqui também
            };

            # Correção: usuário correto é "borba"
            home-manager.users.borba = { config, pkgs, lib, hostname, ... }: {  # ← recebe hostname
              imports = [
                ./home.nix
                # Theme: Catppuccin Home Manager module
                catppuccin.homeManagerModules.catppuccin
                # Outros módulos podem usar hostname se necessário
              ];
            };
          }
        ];
      };

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
      macbook = mkHost { hostname = "macbook"; system = "x86_64-linux"; };
      dell = mkHost { hostname = "dell"; system = "x86_64-linux"; };
    };

    # ==========================================
    # DevShells (ambientes de desenvolvimento)
    # Usage: nix develop .#rust-dev
    #        nix develop .#go-dev
    # ==========================================
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      fenixPkgs = fenix.packages.${system};

      # Rust toolchains
      rustStable = fenixPkgs.stable.withComponents [
        "rustc"
        "cargo"
        "clippy"
        "rustfmt"
        "rust-analyzer"
        "rust-src"
      ];

      rustNightly = fenixPkgs.complete.withComponents [
        "rustc"
        "cargo"
        "clippy"
        "rustfmt"
        "rust-analyzer"
        "rust-src"
      ];
    in
    {
      # ==========================================
      # DevShell: Rust (stable)
      # ==========================================
      devShells.rust = pkgs.mkShell {
        name = "rust-dev-stable";
        
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          rustStable
          cargo-edit
          cargo-watch
          cargo-make
          cargo-nextest
          
          # Build dependencies comuns
          clang
          llvmPackages.bintools
          openssl
          zlib
        ];

        RUST_SRC_PATH = "${rustStable}/lib/rustlib/src/rust/library";
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        
        shellHook = ''
          echo "🦀 Rust Development Environment (stable)"
          echo "Rust version: $(rustc --version)"
          echo "Cargo version: $(cargo --version)"
          echo ""
          echo "Available tools:"
          echo "  - cargo-edit, cargo-watch, cargo-make, cargo-nextest"
          echo "  - clippy, rustfmt, rust-analyzer"
        '';
      };

      # ==========================================
      # DevShell: Rust (nightly)
      # ==========================================
      devShells.rust-nightly = pkgs.mkShell {
        name = "rust-dev-nightly";
        
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];

        buildInputs = with pkgs; [
          rustNightly
          cargo-edit
          cargo-watch
          cargo-make
          cargo-nextest
          
          clang
          llvmPackages.bintools
          openssl
          zlib
        ];

        RUST_SRC_PATH = "${rustNightly}/lib/rustlib/src/rust/library";
        LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
        
        shellHook = ''
          echo "🦀 Rust Development Environment (nightly)"
          echo "Rust version: $(rustc --version)"
          echo "Cargo version: $(cargo --version)"
        '';
      };

      # ==========================================
      # DevShell: Go
      # ==========================================
      devShells.go = pkgs.mkShell {
        name = "go-dev";
        
        buildInputs = with pkgs; [
          go_1_25
          gopls
          delve
          gotools
          gofumpt
          golangci-lint
          go-task
          air  # Hot reload
        ];

        shellHook = ''
          echo "🐹 Go Development Environment"
          echo "Go version: $(go version)"
          echo ""
          echo "Environment:"
          echo "  GOPATH=$GOPATH"
          echo "  GOBIN=$GOBIN"
          echo ""
          echo "Available tools:"
          echo "  - gopls, delve, gofumpt, golangci-lint"
          echo "  - go-task (task runner), air (hot reload)"
        '';

        # Go environment
        GOPATH = "${builtins.getEnv "HOME"}/go";
        GOBIN = "${builtins.getEnv "HOME"}/go/bin";
      };

      # ==========================================
      # DevShell: Full Stack (Rust + Go + Node)
      # ==========================================
      devShells.fullstack = pkgs.mkShell {
        name = "fullstack-dev";
        
        buildInputs = with pkgs; [
          # Rust
          rustStable
          cargo-edit
          cargo-watch
          
          # Go
          go_1_25
          gopls
          delve
          
          # Node.js
          nodejs_20
          nodePackages.pnpm
          
          # Tools
          git
          gh
        ];

        shellHook = ''
          echo "🚀 Full Stack Development Environment"
          echo "Rust: $(rustc --version)"
          echo "Go: $(go version)"
          echo "Node: $(node --version)"
        '';
      };

      # ==========================================
      # DevShell: Lua
      # ==========================================
      devShells.lua = pkgs.mkShell {
        name = "lua-dev";
        
        buildInputs = with pkgs; [
          lua5_4
          luajit
          luarocks
          lua-language-server
          stylua
          selene
        ];

        shellHook = ''
          echo "🌙 Lua Development Environment"
          echo "Lua: $(lua5.4 -v)"
          echo "LuaJIT: $(luajit -v)"
          echo ""
          echo "Available tools:"
          echo "  - lua-language-server (LSP)"
          echo "  - stylua (formatter)"
          echo "  - selene (linter)"
          echo "  - luarocks (package manager)"
        '';

        LUA_PATH = "${builtins.getEnv "HOME"}/.luarocks/share/lua/5.4/?.lua;${builtins.getEnv "HOME"}/.luarocks/share/lua/5.4/?/init.lua;;";
        LUA_CPATH = "${builtins.getEnv "HOME"}/.luarocks/lib/lua/5.4/?.so;;";
      };

      # ==========================================
      # DevShell: Nix Development
      # ==========================================
      devShells.nix-dev = pkgs.mkShell {
        name = "nix-dev";
        
        buildInputs = with pkgs; [
          nixpkgs-fmt
          alejandra
          nil
          nixd
          nix-tree
          nix-diff
          nix-update
          nix-init
          statix
          deadnix
        ];

        shellHook = ''
          echo "❄️  Nix Development Environment"
          echo ""
          echo "Available tools:"
          echo "  Formatters: nixpkgs-fmt, alejandra"
          echo "  LSPs: nil, nixd"
          echo "  Analysis: nix-tree, nix-diff, statix, deadnix"
          echo "  Utilities: nix-update, nix-init"
          echo ""
          echo "Quick commands:"
          echo "  nixpkgs-fmt .     # Format all .nix files"
          echo "  statix check .    # Lint for issues"
          echo "  deadnix .         # Find dead code"
        '';

        NIX_PATH = "nixpkgs=${pkgs.path}";
      };

      # DevShell padrão (aponta para fullstack)
      devShells.default = pkgs.mkShell {
        name = "dev";
        
        buildInputs = with pkgs; [
          rustStable
          go_1_25
          nodejs_20
        ];

        shellHook = ''
          echo "💻 Default Development Environment"
          echo "Use shells específicos para mais ferramentas:"
          echo "  nix develop .#rust         → Rust stable"
          echo "  nix develop .#rust-nightly → Rust nightly"
          echo "  nix develop .#go           → Go com extras"
          echo "  nix develop .#lua          → Lua + LuaJIT"
          echo "  nix develop .#nix-dev      → Nix development tools"
          echo "  nix develop .#fullstack    → Rust + Go + Node"
        '';
      };
    }
  );
}
