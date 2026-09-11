;;; init.el -*- lexical-binding: t; -*-

(doom! :input

     :completion
     (company +childframe)     ; autocompletar
     (vertico +icons)          ; minibuffer moderno

     :ui
     doom                      ; tema/UI base do Doom
     doom-dashboard
     hl-todo                   ; destaca TODO/FIXME/NOTE
     (ligatures +extra)
     indent-guides
     modeline
     nav-flash
     ophints
     (popup +defaults)
     treemacs                  ; sidebar de arquivos
     vc-gutter                 ; sinais de git na margem
     vi-tilde-fringe
     workspaces

     :editor
     (evil +everywhere)        ; keybindings estilo Vim
     file-templates
     fold
     (format +onsave)          ; formata ao salvar (gofmt, rustfmt, black, alejandra...)
     multiple-cursors
     snippets

     :emacs
     dired
     electric
     undo
     vc

     :term
     vterm

     :checkers
     syntax                    ; flycheck
     (spell +flyspell)
     grammar

     :tools
     direnv                    ; <- integra com seus devshells `nix develop`
     (eval +overlay)
     lookup
     (lsp +peek)               ; LSP para todas as linguagens abaixo
     magit                     ; git
     make
     pdf
     tree-sitter               ; parsing melhor de sintaxe (rust/go/python se beneficiam bastante)

     :os
     (:if IS-MAC macos)
     tty

     :lang
     emacs-lisp
     (go +lsp +tree-sitter)
     (lua +lsp +tree-sitter)   ; cobre Lua puro e configs de Neovim/AwesomeWM
     markdown
     (nix +tree-sitter)        ; nix-mode, formata com nixpkgs-fmt/alejandra
     org
     (python +lsp +tree-sitter +pyright)
     (rust +lsp +tree-sitter)
     sh
     (yaml +lsp)
     (json +lsp)

     :config
     (default +bindings +smartparens))
