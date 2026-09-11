;;; config.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;; Identidade / básico
;; ---------------------------------------------------------------------------
(setq user-full-name "Borba Jr."
      doom-theme 'doom-one
      display-line-numbers-type 'relative
      doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14))

;; ---------------------------------------------------------------------------
;; direnv — essencial pro seu fluxo de `nix develop` por devshell
;; ---------------------------------------------------------------------------
(after! direnv
  (direnv-mode +1))

;; ---------------------------------------------------------------------------
;; Rust
;; ---------------------------------------------------------------------------
(after! rustic
  (setq rustic-lsp-client 'lsp-mode
        rustic-format-on-save t          ; usa rustfmt (ou o que seu devshell expõe)
        rustic-cargo-use-last-stored-arguments t))

(after! lsp-rust
  (setq lsp-rust-analyzer-cargo-watch-command "clippy"   ; clippy no watch, não só check
        lsp-rust-analyzer-display-parameter-hints t
        lsp-rust-analyzer-display-chaining-hints t
        lsp-rust-analyzer-proc-macro-enable t))

;; ---------------------------------------------------------------------------
;; Go
;; ---------------------------------------------------------------------------
(after! go-mode
  (setq gofmt-command "goimports")       ; organiza imports junto com o format
  (add-hook 'go-mode-local-vars-hook #'lsp! ))

(after! lsp-go
  (setq lsp-go-analyses '((unusedparams . t)
                           (shadow . t)
                           (nilness . t))
        lsp-go-use-gofumpt t))           ; mais estrito que gofmt puro

;; ---------------------------------------------------------------------------
;; Python
;; ---------------------------------------------------------------------------
(after! python
  (setq python-shell-interpreter "python3"))

(after! lsp-pyright
  (setq lsp-pyright-typechecking-mode "basic"))

;; Se seus devshells Python usam venv/poetry/uv, ative pyvenv-tracking:
(use-package! pyvenv
  :after python
  :config
  (pyvenv-mode +1))

;; ---------------------------------------------------------------------------
;; Lua
;; ---------------------------------------------------------------------------
(setq lua-indent-level 2)

(after! lsp-mode
  (set-lsp-priority! 'lua-language-server 1))

;; ---------------------------------------------------------------------------
;; Nix
;; ---------------------------------------------------------------------------
(after! nix-mode
  (setq nix-nixfmt-bin "alejandra"))     ; você já usa alejandra no treefmt-nix

;; formata arquivos .nix ao salvar via `format` module + alejandra
(set-formatter! 'alejandra "alejandra" :modes '(nix-mode))

;; ---------------------------------------------------------------------------
;; LSP geral — evita travar em repos grandes (flakes com muitos hosts, etc.)
;; ---------------------------------------------------------------------------
(setq lsp-idle-delay 0.3
      lsp-log-io nil
      lsp-headerline-breadcrumb-enable t
      read-process-output-max (* 1024 1024)) ; 1mb, ajuda LSPs como rust-analyzer/gopls

;; ---------------------------------------------------------------------------
;; Projectile — reconhece seus devshells como raiz de projeto
;; ---------------------------------------------------------------------------
(after! projectile
  (setq projectile-project-root-files-bottom-up
        (append '("flake.nix" ".envrc") projectile-project-root-files-bottom-up)))
