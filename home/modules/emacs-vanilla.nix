{
  pkgs,
  config,
  lib,
  ...
}: let
  configs = ../configs;

  myEmacs = pkgs.emacs.pkgs.withPackages (epkgs: [
    epkgs.nix-mode
    epkgs.lua-mode
    epkgs.go-mode
    epkgs.rust-mode
    epkgs.treesit-auto
    epkgs.envrc
    epkgs.magit
    epkgs.eat
    epkgs.consult
    epkgs.embark
    epkgs.embark-consult
    epkgs.which-key
    epkgs.diff-hl
    epkgs.hl-todo
    epkgs.yaml-mode
    epkgs.toml-mode
    epkgs.rainbow-delimiters
    epkgs.avy
    epkgs.tempel
    epkgs.dape
    epkgs.use-package
    epkgs.catppuccin-theme
    epkgs.vertico
    epkgs.orderless
    epkgs.marginalia
    epkgs.cape
    epkgs.helpful
    epkgs.markdown-mode
    epkgs.apheleia
    epkgs.corfu
    epkgs.corfu-terminal
    epkgs.popon
  ]);

  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-grammars (
    grammars:
      with grammars; [
        tree-sitter-nix
        tree-sitter-lua
        tree-sitter-go
        tree-sitter-python
      ]
  );
in {
  config = lib.mkIf config.editors.emacs.enable {
    home.packages = [
      myEmacs
      treesitGrammars
      pkgs.rustfmt
      pkgs.gopls
      pkgs.go
      pkgs.gotools
      pkgs.lua-language-server
      pkgs.stylua
      pkgs.nixd
      pkgs.nil
      pkgs.pyright
      pkgs.black
      pkgs.alejandra
    ];

    xdg.configFile."emacs" = {
      source = "${configs}/emacs";
      recursive = true;
    };

    home.sessionVariables = {
      EMACS_TREESIT_GRAMMAR_PATH = "${treesitGrammars}/lib";
    };

    home.activation.removeLegacyEmacsInit = lib.hm.dag.entryBefore ["writeBoundary"] ''
      for f in "$HOME/.emacs" "$HOME/.emacs.el" "$HOME/.emacs.d"; do
        if [ -e "$f" ] && [ ! -L "$f" ]; then
          backup="$f.pre-nix-backup"
          if [ -e "$backup" ] || [ -L "$backup" ]; then
            $DRY_RUN_CMD rm -rf "$backup"
          fi
          $DRY_RUN_CMD mv $VERBOSE_ARG "$f" "$backup"
        fi
      done
    '';
  };
}
