# { config, pkgs, lib, ... }:

# {
#   home.packages = [
#     (pkgs.rust-bin.stable.latest.default.override {
#       extensions = [
#         "rust-src"        # essencial para rust-analyzer
#         "rust-analyzer"
#         "clippy"
#         "rustfmt"
#       ];
#     })
#     # Adicione se precisar (muito comum para crates)
#     # pkgs.pkg-config
#     # pkgs.openssl
#   ];

#   # Remova completamente essas linhas (conflitam com o overlay puro):
#   # RUSTUP_HOME, CARGO_HOME, sessionPath para ~/.cargo/bin
#   # Qualquer home.activation com rustup
# }

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # 🦀 Rust toolchain (via rust-overlay)
    (rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"        # necessário para rust-analyzer
        "rust-analyzer"
        "clippy"
        "rustfmt"
      ];
    })

    # 🧰 Cargo tools (produtividade)
    cargo-edit        # cargo add / rm
    cargo-watch       # rebuild on change
    cargo-audit       # CVEs
    cargo-outdated    # deps desatualizadas
    cargo-deny        # policy / licenses

    # 🐞 Debug / build support
    lldb
    pkg-config
    openssl
  ];
}
