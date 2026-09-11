{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy

    # Resto do commonBuildInputs do devshells/rust que tinha ficado de fora
    # (só os pacotes — RUSTC_WRAPPER=sccache e RUSTFLAGS=-fuse-ld=mold do
    # shellHook original ficaram fora de propósito: system-wide isso muda o
    # link de todo build de Rust da máquina, não só o do devshell)
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
    gdb
    lldb

    # Utilitários genéricos do commonBuildInputs que tinham ficado de fora
    clang
    llvmPackages.bintools
    pkg-config
    openssl
    zlib
    git
    gnumake
    jq
    ripgrep
    fd
    tree
  ];
}
