{
  inputs,
  pkgs,
  ...
}: let
  # emacs-pgtk = build nativa GTK (ícones, transparência, melhor suporte a
  # Wayland/X11), vinda do overlay nix-community/emacs-overlay aplicado
  # globalmente em modules/nixos/users-and-home.nix (nixpkgs.overlays) —
  # o emacs-overlay NÃO expõe essas variantes como saída de flake
  # (`packages.${system}.emacs-pgtk` não existe), só via overlay em cima do
  # pkgs normal. Nome do atributo mudou de emacsPgtk (camelCase, deprecado)
  # pra emacs-pgtk (kebab-case) — nixpkgs ganhou um emacs-pgtk próprio e o
  # overlay renomeou o dele pra não colidir. Outras opções que o mesmo
  # overlay injeta em pkgs, se quiser trocar depois: pkgs.emacs-unstable,
  # pkgs.emacs-git, pkgs.emacs-pgtk-native-comp (compilação nativa, build
  # mais lento porém mais rápido em uso).
  doomEmacs = pkgs.emacs-pgtk;

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
    aspellDicts.en # :checkers spell precisa de um spellchecker de verdade no PATH

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
    doomDir = ../configs/doom; # espera init.el / config.el / packages.el aqui
    emacs = doomEmacs;
  };

  home.packages = doomExtraPackages;

  # referenciado no config.el via `treesit-extra-load-path`
  home.sessionVariables = {
    EMACS_TREESIT_GRAMMAR_PATH = "${pkgs.emacsPackages.treesit-grammars.with-grammars (g: with g; [tree-sitter-rust tree-sitter-go tree-sitter-python tree-sitter-nix])}/lib";
  };
}
