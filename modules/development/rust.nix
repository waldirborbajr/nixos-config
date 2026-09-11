{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf config.development.languages.rust.enable {
  # Somente Rust e ferramentas específicas do ecossistema Rust.
  # As ferramentas comuns (clang, pkg-config, openssl, zlib, git, gdb,
  # SQLite, Helix, etc.) vivem em base.nix.
  environment.systemPackages = with pkgs; [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    cargo-edit
    cargo-watch
    cargo-make
    cargo-nextest
    bacon
    mold
    sccache
    cargo-tarpaulin
    cargo-audit
    cargo-outdated
    llvmPackages.bintools
  ];
  };
}
