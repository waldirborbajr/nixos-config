{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Toolchain LaTeX/Typst e utilitários específicos desse fluxo.
  environment.systemPackages = with pkgs; [
    texlive.combined.scheme-full
    tex-fmt
    typst
    tinymist
    zathura
    sioyek
    entr
    just
  ];
}
