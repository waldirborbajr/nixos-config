{ config, pkgs, lib, ... }:

let
  RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
  CARGO_HOME  = "${config.home.homeDirectory}/.cargo";
  CARGO_BIN   = "${CARGO_HOME}/bin";
in
{
  home.packages = with pkgs; [
    rustup
    # Opcional: ajuda a evitar alguns conflitos de binários
    # rust-analyzer   # ← descomente se quiser o oficial do Nix
  ];

  home.sessionVariables = {
    RUSTUP_HOME = RUSTUP_HOME;
    CARGO_HOME  = CARGO_HOME;
    # Ajuda o rustup a encontrar o linker no NixOS
    RUSTFLAGS = "-C link-arg=-fuse-ld=lld";
  };

  home.sessionPath = [ CARGO_BIN ];

  # ── Script de ativação mais robusto e com debug ─────────────────────────────
  home.activation.installRustToolchain = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail

    TOOLCHAIN_DIR="${RUSTUP_HOME}/toolchains/stable-x86_64-unknown-linux-gnu"
    if [ ! -x "$TOOLCHAIN_DIR/bin/rustc" ]; then
      echo ">> Instalando toolchain Rust stable (pode demorar na primeira vez)"
      ${pkgs.rustup}/bin/rustup toolchain install stable --profile default
      echo ">> Adicionando componentes úteis"
      ${pkgs.rustup}/bin/rustup component add \
        rustfmt \
        clippy \
        rust-src \
        rust-analyzer \
        --toolchain stable
      echo ">> Definindo stable como default"
      ${pkgs.rustup}/bin/rustup default stable
      echo ">> Rust instalado com sucesso!"
    else
      echo ">> Rust stable toolchain já existe, pulando instalação"
    fi

    # Força atualização do PATH no shell atual (útil para debug imediato)
    echo ">> Verifique: $(which cargo || echo 'cargo não encontrado ainda')"
  '';

  # Opcional: força recriação do toolchain se algo der errado
  # home.activation.alwaysCheckRust = lib.hm.dag.entryAfter [ "installRustToolchain" ] ''
  #   ${pkgs.rustup}/bin/rustup toolchain list
  # '';
}
