{pkgs, ...}: let
  configs = ../configs;

  myEmacs = pkgs.emacs.pkgs.withPackages (epkgs: [
    # major-modes que o Emacs core não traz
    epkgs.nix-mode
    epkgs.lua-mode
    epkgs.go-mode # fallback caso não use go-ts-mode
    epkgs.rust-mode # fallback caso não use rust-ts-mode

    # sua stack de eglot
    epkgs.treesit-auto

    # integra com seus devshells `nix develop`
    epkgs.envrc

    # opcional, combina com o resto do repo
    epkgs.magit
  ]);

  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-grammars (grammars:
    with grammars; [
      tree-sitter-nix
      tree-sitter-lua
      tree-sitter-go
      tree-sitter-rust
      tree-sitter-python
    ]);
in {
  home.packages = [
    myEmacs
    treesitGrammars

    # Descomente para ter os LSPs disponíveis fora de devshells/:
    # pkgs.rust-analyzer
    # pkgs.gopls
    # pkgs.lua-language-server
    # pkgs.nixd
    # pkgs.pyright
  ];

  xdg.configFile."emacs" = {
    source = "${configs}/emacs";
    recursive = true;
  };

  # grammars pré-compiladas pelo nix — sem precisar de gcc/libtool em runtime.
  # referenciado no init.el via:
  #   (setq treesit-extra-load-path
  #         (list "${treesitGrammars}/lib"))
  home.sessionVariables = {
    EMACS_TREESIT_GRAMMAR_PATH = "${treesitGrammars}/lib";
  };
}
