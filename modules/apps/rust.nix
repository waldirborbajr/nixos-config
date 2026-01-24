# modules/apps/rust.nix
{ config, pkgs, lib, ... }:

{
  # Rustup (recomendado) + rust-analyzer + ferramentas comuns
  home.packages = with pkgs; [
    rustup
    rust-analyzer     # LSP (para Neovim / VSCode)
    cargo-edit        # cargo add / rm / upgrade
    cargo-watch       # watch + rebuild automático
    cargo-make        # task runner (makefiles em Rust)
    cargo-nextest     # test runner mais rápido
  ];

  # Opcional: aliases úteis para Rust/DevOps
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    ru      = "rustup update";                    # atualiza todas as toolchains
    rc      = "cargo check";                     # checa sem compilar
    rb      = "cargo build --release";            # build release
    rt      = "cargo test -- --nocapture";        # testes com output
    rtw     = "cargo watch -x 'test -- --nocapture'";  # watch + test
    rr      = "cargo run --release";              # roda release
    rf      = "cargo fmt";                        # formata
    rl      = "cargo clippy --all-targets -- -D warnings";  # linter estrito
    ra      = "cargo add";                        # cargo add (cargo-edit)
    ruu     = "cargo upgrade";                    # atualiza Cargo.toml (cargo-edit)
    rdoc    = "cargo doc --open";                 # abre doc local
  };

  # Opcional: ativação para instalar toolchain stable na primeira vez
  # (rode manualmente na primeira ativação: rustup toolchain install stable)
  home.activation = {
    ensureRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Lembrete: rode manualmente na primeira vez:"
      echo "  rustup toolchain install stable"
      echo "  rustup default stable"
      echo "  rustup component add rust-analyzer rls rust-src rustfmt clippy"
    '';
  };
}
