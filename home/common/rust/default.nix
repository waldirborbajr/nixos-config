{ config, pkgs, lib, ... }:

let
  RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
  CARGO_HOME  = "${config.home.homeDirectory}/.cargo";
  CARGO_BIN   = "${CARGO_HOME}/bin";
in
{
  ############################################
  # Rust / Rustup
  ############################################

  home.packages = with pkgs; [
    rustup
  ];

  home.sessionVariables = {
    RUSTUP_HOME = RUSTUP_HOME;
    CARGO_HOME  = CARGO_HOME;
  };

  home.sessionPath = [
    CARGO_BIN
  ];

  ############################################
  # Install default Rust toolchain (stable)
  ############################################
  home.activation.installRustToolchain =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "${RUSTUP_HOME}/toolchains/stable-x86_64-unknown-linux-gnu/bin/rustc" ]; then
        echo ">> Installing Rust stable toolchain"
        ${pkgs.rustup}/bin/rustup toolchain install stable
        ${pkgs.rustup}/bin/rustup component add \
          rustfmt \
          clippy \
          rust-src \
          rust-analyzer
        ${pkgs.rustup}/bin/rustup default stable
      fi
    '';
}
