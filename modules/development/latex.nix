{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/latex (nix develop). Traz o toolchain LaTeX+Typst
# pro sistema inteiro em vez de por-projeto; os aliases/justfile do shellHook
# original (latex-build, typst-build, etc.) não fazem sentido fora de um
# devshell, então ficaram de fora — só os pacotes.
{
  environment.systemPackages = with pkgs; [
    # LaTeX toolchain
    texlive.combined.scheme-full
    tex-fmt

    # Typst toolchain
    typst
    tinymist # language server pro Typst

    # Preview
    zathura
    sioyek

    # Utilidades
    watchexec
    entr
    just
    helix
  ];
}
