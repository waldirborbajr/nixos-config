{ config, pkgs, lib, ... }:

let
  # Cria um pkgs local só com o overlay (fallback se global não funcionar)
  rustPkgs = import pkgs.nixpkgs {
    inherit (pkgs) system;
    overlays = [ (import <rust-overlay>) ];  # ou use inputs se disponível
  };
in
{
  home.packages = [
    (rustPkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rust-src" "rust-analyzer" "clippy" "rustfmt" ];
    })
  ];
}
