{ config, pkgs, lib, ... }:

{
  home.packages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"        # essencial para rust-analyzer
        "rust-analyzer"
        "clippy"
        "rustfmt"
      ];
    })
    # Adicione se precisar (muito comum para crates)
    # pkgs.pkg-config
    # pkgs.openssl
  ];

  # Remova completamente essas linhas (conflitam com o overlay puro):
  # RUSTUP_HOME, CARGO_HOME, sessionPath para ~/.cargo/bin
  # Qualquer home.activation com rustup
}
