# modules/apps/rust.nix
{ config, pkgs, lib, ... }:

{
  # Só rustup (remove rust-analyzer standalone para evitar conflito)
  home.packages = with pkgs; [
    rustup
    cargo-edit
    cargo-watch
    cargo-make
    cargo-nextest
  ];

  # Opcional: aliases úteis para Rust/DevOps
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    ru      = "rustup update";                    # atualiza toolchains
    rc      = "cargo check";
    rb      = "cargo build --release";
    rt      = "cargo test -- --nocapture";
    rtw     = "cargo watch -x 'test -- --nocapture'";
    rr      = "cargo run --release";
    rf      = "cargo fmt";
    rl      = "cargo clippy --all-targets -- -D warnings";
    ra      = "cargo add";
    ruu     = "cargo upgrade";
    rdoc    = "cargo doc --open";
  };

  # Lembrete para instalar componentes (rode manualmente na primeira vez)
  home.activation = {
    ensureRustup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      echo "Lembrete: rode manualmente na primeira ativação:"
      echo "  rustup toolchain install stable"
      echo "  rustup default stable"
      echo "  rustup component add rust-analyzer rls rust-src rustfmt clippy"
    '';
  };
}
