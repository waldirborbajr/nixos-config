;;; init.el --- Rust/Go/Lua/Nix + OneNord -*- lexical-binding: t; -*-
;;
;; Config enxuta baseada nos built-ins modernos do Emacs (eglot pra LSP,
;; treesit-auto pra tree-sitter) em vez de lsp-mode/lsp-bridge — menos
;; dependência externa, mais rápido de subir. Requer Emacs 29+.

;;; Tema

(add-to-list 'custom-theme-load-path
              (expand-file-name "themes" user-emacs-directory))
(load-theme 'onenord t)

;;; Gerenciador de pacotes

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; Defaults sãos

(setq inhibit-startup-message t
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      ring-bell-function 'ignore
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(column-number-mode 1)
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(show-paren-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(setq-default indent-tabs-mode nil
              tab-width 4)

;; U pra redo, espelhando o bind do Helix.
(global-set-key (kbd "M-U") #'undo-redo)

;;; Completion: vertico + orderless (minibuffer) + corfu (in-buffer)

(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  :init (global-corfu-mode))

(use-package which-key
  :init (which-key-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;;; Tree-sitter (mapeia automaticamente pro modo -ts- quando disponível)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (global-treesit-auto-mode))

;;; LSP via eglot (built-in desde o Emacs 29)

(use-package eglot
  :ensure nil
  :hook ((rust-mode rust-ts-mode) . eglot-ensure)
  :hook ((go-mode go-ts-mode) . eglot-ensure)
  :hook ((lua-mode lua-ts-mode) . eglot-ensure)
  :hook ((nix-mode nix-ts-mode) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '((nix-mode nix-ts-mode) . ("nixd")))
  (add-to-list 'eglot-server-programs '((lua-mode lua-ts-mode) . ("lua-language-server"))))

;;; Rust

(use-package rustic
  :custom
  (rustic-lsp-client 'eglot)
  (rustic-format-on-save t)
  (rustic-cargo-use-last-stored-arguments t))

;;; Go

(use-package go-mode
  :hook (go-mode . (lambda ()
                      (setq tab-width 4)
                      (add-hook 'before-save-hook #'gofmt-before-save nil t)))
  :hook (go-mode . eglot-ensure))

;;; Lua

(use-package lua-mode
  :mode "\\.lua\\'"
  :custom
  (lua-indent-level 2))

;;; Nix

(use-package nix-mode
  :mode "\\.nix\\'")

;;; Git

(use-package magit
  :bind ("C-x g" . magit-status))

(provide 'init)
;;; init.el ends here
