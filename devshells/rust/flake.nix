{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      fenix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        fenixPkgs = fenix.packages.${system};

        stableToolchain = fenixPkgs.stable.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rustfmt"
          "rust-analyzer"
          "rust-src"
        ];

        nightlyToolchain = fenixPkgs.complete.withComponents [
          "rustc"
          "cargo"
          "clippy"
          "rustfmt"
          "rust-analyzer"
          "rust-src"
        ];

        stableShell = pkgs.mkShell {
          name = "rust-dev-stable";

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            stableToolchain
            cargo-edit
            cargo-watch
            cargo-make
            cargo-nextest
            clang
            llvmPackages.bintools
            mold
            sccache
            openssl
            zlib
            postgresql
            mariadb.client
            sqlite
            usql
            pgcli
            mycli
            litecli
          ];

          RUST_SRC_PATH = "${stableToolchain}/lib/rustlib/src/rust/library";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
          RUSTFLAGS = "-C link-arg=-fuse-ld=mold";

          shellHook = ''
            echo "🦀 Rust Development Environment (stable)"
            echo "Rust version: $(rustc --version)"
            echo "Cargo version: $(cargo --version)"
            echo ""
            echo "Available tools:"
            echo "  - cargo-edit, cargo-watch, cargo-make, cargo-nextest"
            echo "  - clippy, rustfmt, rust-analyzer"
            echo "  - mold (linker) + sccache (compile cache) ativos via RUSTFLAGS/RUSTC_WRAPPER"
          '';
        };

        nightlyShell = pkgs.mkShell {
          name = "rust-dev-nightly";

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            nightlyToolchain
            cargo-edit
            cargo-watch
            cargo-make
            cargo-nextest
            clang
            llvmPackages.bintools
            mold
            sccache
            openssl
            zlib
            postgresql
            mariadb.client
            sqlite
            usql
            pgcli
            mycli
            litecli
          ];

          RUST_SRC_PATH = "${nightlyToolchain}/lib/rustlib/src/rust/library";
          LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
          RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
          RUSTFLAGS = "-C link-arg=-fuse-ld=mold";

          shellHook = ''
            echo "🦀 Rust Development Environment (nightly)"
            echo "Rust version: $(rustc --version)"
            echo "Cargo version: $(cargo --version)"
            echo "  - mold (linker) + sccache (compile cache) ativos via RUSTFLAGS/RUSTC_WRAPPER"
          '';
        };
      in
      {
        devShells = {
          default = stableShell;
          rust = stableShell;
          rust-nightly = nightlyShell;
        };
      }
    );
}