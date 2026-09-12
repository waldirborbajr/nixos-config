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

    # eglot só fornece `completion-at-point-functions`, sem UI nenhuma —
    # sem isso não existe popup de autocomplete em NENHUMA linguagem
    # (rust/go/nix/python/lua sofrem igual, não é específico do Rust).
    epkgs.corfu
    epkgs.corfu-terminal # fallback pro corfu quando roda `emacs -nw` (sem child-frame)
    epkgs.popon # dependência do corfu-terminal
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

    # Sem `.envrc`/devshell (ex: pastas soltas tipo aoc-tasks, sem flake
    # próprio), o `direnv`/`envrc-mode` não injeta nada no PATH e o eglot
    # não acha o LSP — falha calada dentro do hook `eglot-ensure`, sem
    # avisar, e sem LSP não tem autocomplete nem diagnóstico de erro.
    # Instalando global aqui funciona como fallback; projetos com devshell
    # continuam pegando a versão pinada de lá via direnv normalmente.
    pkgs.rust-analyzer
    pkgs.gopls
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.pyright
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
