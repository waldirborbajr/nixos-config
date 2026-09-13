{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.rust.enable {
    # ══════════════════════════════════════════════════════════════════════
    #  Rust Toolchain — Sincronizado via rust-bin
    #
    #  Por que rust-bin?
    #  - Todos os componentes (rustc, cargo, rust-analyzer, rustfmt, clippy)
    #    vêm do MESMO release oficial, evitando incompatibilidades.
    #  - O rust-analyzer do nixpkgs costuma ficar desatualizado em relação
    #    ao rustc, causando falsos positivos (ex: "cannot index into &[i32]").
    # ══════════════════════════════════════════════════════════════════════

    environment.systemPackages = with pkgs; [
      # ── Toolchain unificado (rustc + cargo + rust-analyzer + rustfmt + clippy)
      (rust-bin.stable.latest.default.override {
        extensions = [
          "rust-src"        # Código-fonte da std (útil para rust-analyzer)
          "rust-analyzer"   # LSP
          "rustfmt"         # Formatador
          "clippy"          # Linter
        ];

        targets = [
          # Adicione targets cross-compilation se precisar
          # "x86_64-unknown-linux-musl"
          # "aarch64-unknown-linux-gnu"
        ];
      })

      # ── Ferramentas do ecossistema Rust ────────────────────────────────
      cargo-edit        # `cargo add`, `cargo rm`, `cargo upgrade`
      cargo-watch       # `cargo watch` (rebuild automático)
      cargo-make        # Task runner (Makefile.toml)
      cargo-nextest     # Test runner moderno
      cargo-tarpaulin   # Coverage
      cargo-audit       # Auditoria de segurança (CVEs)
      cargo-outdated    # Dependências desatualizadas
      bacon             # Background code checker

      # ── Aceleração de build / link ─────────────────────────────────────
      mold              # Linker rápido
      sccache           # Cache de compilação
      llvmPackages.bintools  # lld, llvm-ar, etc.

      # ── Debug ──────────────────────────────────────────────────────────
      # (gdb já está em base.nix, mas se quiser garantir)
      # gdb
    ];

    # ── Variáveis de ambiente úteis para Rust ──────────────────────────────
    environment.variables = {
      # Usa mold como linker padrão (muito mais rápido que o linker padrão)
      RUSTFLAGS = "-C link-arg=-fuse-ld=mold";

      # Habilita sccache para cachear compilações
      RUSTC_WRAPPER = "${pkgs.sccache}/bin/sccache";

      # Desabilita telemetria do cargo
      CARGO_TERM_COLOR = "always";
    };

    # ── sccache: diretório de cache ────────────────────────────────────────
    # Opcional: se quiser um cache persistente em disco maior
    # environment.variables.SCCACHE_DIR = "/var/cache/sccache";
  };
}
