;;; init.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;; Básico
;; ---------------------------------------------------------------------------
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      make-backup-files nil
      auto-save-default nil
      use-short-answers t)

(global-display-line-numbers-mode 1)
(column-number-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(recentf-mode 1)
(savehist-mode 1)

;; ---------------------------------------------------------------------------
;; Grammars do tree-sitter — pré-compiladas pelo Nix (emacs-vanilla.nix),
;; nunca compiladas em runtime.
;; ---------------------------------------------------------------------------
(let ((grammar-path (getenv "EMACS_TREESIT_GRAMMAR_PATH")))
  (when grammar-path
    (setq treesit-extra-load-path (list grammar-path))))

(require 'treesit-auto)
(setq treesit-auto-install nil)     ; grammars vêm do Nix, nunca de compilação em runtime
(global-treesit-auto-mode 1)

;; ---------------------------------------------------------------------------
;; Completion popup (corfu) — eglot fornece só `completion-at-point-functions`,
;; nenhuma UI. Sem isso não tem autocomplete visual em nenhuma linguagem,
;; não é algo específico do Rust: precisa disso antes do `require 'eglot`
;; pra já estar disponível quando o primeiro LSP conectar.
;; ---------------------------------------------------------------------------
(require 'corfu)
(setq corfu-auto t
      corfu-auto-delay 0.15
      corfu-auto-prefix 1
      corfu-cycle t)
(global-corfu-mode 1)

;; child-frame do corfu não funciona em `emacs -nw` — cai pro corfu-terminal
(unless (display-graphic-p)
  (require 'corfu-terminal)
  (corfu-terminal-mode 1))

;; ---------------------------------------------------------------------------
;; direnv — pega o PATH/env de cada `nix develop` automaticamente
;; ---------------------------------------------------------------------------
(require 'envrc)
(envrc-global-mode)

;; ---------------------------------------------------------------------------
;; eglot — LSP builtin do Emacs 29+
;; ---------------------------------------------------------------------------
(require 'eglot)
(setq eglot-autoshutdown t
      eglot-sync-connect nil
      eglot-events-buffer-size 0)     ; menos overhead de log por sessão longa

;; formata com o LSP server ao salvar, quando o buffer está sob eglot
(add-hook 'before-save-hook
          (lambda ()
            (when (eglot-managed-p)
              (eglot-format-buffer))))

(dolist (hook '(rust-ts-mode-hook rust-mode-hook
                go-ts-mode-hook   go-mode-hook
                python-ts-mode-hook python-mode-hook
                lua-mode-hook
                nix-mode-hook nix-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;; associação explícita de servers (garante mesmo se o eglot não inferir sozinho)
(with-eval-after-load 'eglot
  (dolist (mapping '(((rust-ts-mode rust-mode) . ("rust-analyzer"))
                      ((go-ts-mode go-mode) . ("gopls"))
                      ((python-ts-mode python-mode) . ("pyright-langserver" "--stdio"))
                      (lua-mode . ("lua-language-server"))
                      ((nix-mode nix-ts-mode) . ("nixd"))))
    (add-to-list 'eglot-server-programs mapping)))

;; ---------------------------------------------------------------------------
;; Rust
;; ---------------------------------------------------------------------------
(setq rust-format-on-save nil)      ; deixa o eglot/rust-analyzer cuidar da formatação

;; ---------------------------------------------------------------------------
;; Go
;; ---------------------------------------------------------------------------
(dolist (hook '(go-mode-hook go-ts-mode-hook))
  (add-hook hook (lambda ()
                   (setq indent-tabs-mode t
                         tab-width 4))))

(with-eval-after-load 'go-mode
  (setq gofmt-command "goimports"))  ; organiza imports junto com o format

;; ---------------------------------------------------------------------------
;; Python
;; ---------------------------------------------------------------------------
(setq python-indent-guess-indent-offset nil
      python-shell-interpreter "python3")

;; ---------------------------------------------------------------------------
;; Lua
;; ---------------------------------------------------------------------------
(setq lua-indent-level 2)

;; ---------------------------------------------------------------------------
;; Nix
;; ---------------------------------------------------------------------------
(with-eval-after-load 'nix-mode
  (setq nix-nixfmt-bin "alejandra"))  ; mesmo formatter do seu treefmt-nix

;; ---------------------------------------------------------------------------
;; Magit
;; ---------------------------------------------------------------------------
(global-set-key (kbd "C-x g") #'magit-status)

;; ---------------------------------------------------------------------------
;; project.el — reconhece a raiz por flake.nix / .envrc, sem precisar de projectile
;; ---------------------------------------------------------------------------
(with-eval-after-load 'project
  (add-to-list 'project-vc-extra-root-markers "flake.nix")
  (add-to-list 'project-vc-extra-root-markers ".envrc"))
