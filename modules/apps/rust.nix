{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    rustup
    rust-analyzer
    cargo-edit 
    cargo-watch
  ];

  # Após o primeiro rebuild, rode manualmente:
  # rustup toolchain install stable
  # rustup default stable
  # rustup component add rust-analyzer rls rust-src
}
