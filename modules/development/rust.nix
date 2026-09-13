{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.rust.enable {
    # ══════════════════════════════════════════════════════════════════════
    #  Rust Toolchain — Sincronizado via rust-bin (rust-overlay)
    #
    #  IMPORTANTE: NÃO use `rustc`, `cargo`, `rust-analyzer`, `rustfmt`,
    #  `clippy` individualmente do nixpkgs! Use APENAS o `rust-bin` abaixo.
    #  Caso contrário, o `rust-analyzer` do nixpkgs (antigo) sobrescreve
    #  o do rust-overlay, causando o bug "cannot index into &[i32]".
    # ══════════════════════════════════════════════════════════════════════

    environment.systemPackages = with pkgs; [
      # ── Toolchain unificado (ÚNICA fonte de rustc/cargo/rust-analyzer) ──
      (rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src" # Código-fonte da std
          "rust-analyzer" # LSP (VERSÃO SINCRONIZADA!)
          "rustfmt" # Formatador
          "clippy" # Linter
        ];
      })

      # ── Ferramentas do ecossistema Rust (NÃO são parte do toolchain) ───
      cargo-edit
      cargo-watch
      cargo-make
      cargo-nextest
      cargo-tarpaulin
      cargo-audit
      cargo-outdated
      bacon

      # ── Aceleração de build / link ─────────────────────────────────────
      mold
      sccache
      llvmPackages.bintools
    ];

    # ── Variáveis de ambiente ──────────────────────────────────────────────
    environment.variables = {
      RUSTFLAGS = "-C link-arg=-fuse-ld=mold";
      RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";
      CARGO_TERM_COLOR = "always";
    };
  };
}
