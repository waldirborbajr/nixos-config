{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # LSP
    nixd
    nil

    # Lint / análise estática
    statix
    deadnix

    # Formatter (RFC style)
    nixfmt-rfc-style
  ];
}
