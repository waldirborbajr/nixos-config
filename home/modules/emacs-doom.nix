{inputs, pkgs, ...}: let
  # LSP servers e formatters usados pelo Doom init.el/config.el gerados antes.
  # Deixe comentado se preferir depender só dos devshells/ + direnv (o config.el
  # já ativa `direnv-mode`, então dentro de um projeto com `.envrc` o Doom pega
  # os binários do devshell automaticamente).
  doomExtraPackages = with pkgs; [
    # rust-analyzer
    # gopls
    # lua-language-server
    # nixd
    # pyright
    # alejandra   # já usado pelo nix-mode do doom-config.el

    aspell
    aspellDicts.en   # :checkers spell precisa de um spellchecker de verdade no PATH

    (pkgs.emacsPackages.treesit-grammars.with-grammars (grammars:
      with grammars; [
        tree-sitter-rust
        tree-sitter-go
        tree-sitter-python
        tree-sitter-nix
      ]))
  ];
in {
  imports = [inputs.nix-doom-emacs-unstraightened.hmModule];

  programs.doom-emacs = {
    enable = true;
    doomDir = ../configs/doom;   # espera init.el / config.el / packages.el aqui
    emacs = pkgs.emacs;
  };

  home.packages = doomExtraPackages;

  # referenciado no config.el via `treesit-extra-load-path`
  home.sessionVariables = {
    EMACS_TREESIT_GRAMMAR_PATH = "${pkgs.emacsPackages.treesit-grammars.with-grammars (g: with g; [tree-sitter-rust tree-sitter-go tree-sitter-python tree-sitter-nix])}/lib";
  };
}
