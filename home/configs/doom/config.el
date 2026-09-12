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
;; Tree-sitter — grammars pré-compiladas pelo Nix (emacs-doom.nix), nunca
;; compiladas em runtime. O path do Nix store vem embutido num arquivo
;; gerado pelo home-manager (nix-treesit-grammars.el), não por env var —
;; env var setada via `home.sessionVariables` não chega num Emacs disparado
;; direto pelo niri (não passa por shell de login), o que fazia a gramática
;; nunca ser encontrada. Ainda usado por go/python/nix (rust não usa mais
;; +tree-sitter, ver init.el).
;;
;; NOTA: não usar `doom-user-dir` aqui — o nix-doom-emacs-unstraightened
;; empacota o `doomDir` inteiro (init.el/config.el/packages.el) dentro do
;; Nix store e é ESSE path read-only que vira `doom-user-dir` em runtime,
;; não `~/.config/doom`. O arquivo gerado pelo home-manager (home.file)
;; fica de fato em `~/.config/doom/`, então referenciamos via $HOME.
;; ---------------------------------------------------------------------------
(load (expand-file-name "~/.config/doom/nix-treesit-grammars.el") t)

;; ---------------------------------------------------------------------------
;; Rust
;; ---------------------------------------------------------------------------
;; Fixado ANTES de `rustic` carregar (defcustom simples, não precisa do
;; `after!`) — evita corrida com `rustic-mode-local-vars-hook` no primeiro
;; .rs aberto, que causava "No LSP client named nil".
(setq rustic-lsp-client 'lsp-mode)

;; Primeiro .rs aberto na sessão vinha sem highlight (corrida entre o
;; autoload de `rustic` e a ativação do modo no mesmo buffer) — força o
;; require de `rustic` antes do primeiro arquivo ser aberto, tirando a
;; corrida do caminho.
(add-hook 'doom-first-file-hook (lambda () (require 'rustic nil t)))

(after! rustic
  (setq rustic-format-on-save t          ; usa rustfmt (ou o que seu devshell expõe)
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
