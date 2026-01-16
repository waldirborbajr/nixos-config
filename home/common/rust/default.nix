{ config, pkgs, lib, ... }:

{
  home.packages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"        # para rust-analyzer funcionar bem
        "rust-analyzer"   # LSP oficial
        "clippy"
        "rustfmt"
      ];
    })
    # Opcional: se precisar de wasm, cross, etc.
    # pkgs.pkg-config
    # pkgs.openssl
    # pkgs.cargo-watch
  ];

  # Não precisa mais disso tudo (remova para evitar confusão):
  # RUSTUP_HOME, CARGO_HOME, sessionPath para ~/.cargo/bin
  # script de ativação com rustup
}
