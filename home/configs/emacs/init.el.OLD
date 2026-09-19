;;; init.el --- Development environment -*- lexical-binding: t; -*-

(setq gc-cons-threshold (* 256 1024 1024)
      read-process-output-max (* 4 1024 1024)
      process-adaptive-read-buffering nil)

(require 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 32 1024 1024))))

;; Pacotes vêm 100% do Nix (emacs-vanilla.nix, epkgs.withPackages) — já
;; ficam no load-path, sem precisar de `package-initialize`/MELPA em
;; runtime. Ter DOIS gerenciadores de pacote ativos (Nix + package.el
;; baixando pra ~/.emacs.d/elpa) deixa a ordem do load-path
;; imprevisível — um pacote baixado ali pode sombrear silenciosamente
;; algo embutido do Emacs 30 (o `eglot`, por exemplo) sem erro nenhum
;; aparecer, o que bate com o `:hook` do eglot não disparar sozinho.
(require 'use-package)
(setq use-package-always-ensure nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 080)
(unless (find-font (font-spec :name "JetBrainsMono Nerd Font"))
  (set-face-attribute 'default nil :family "JetBrains Mono"))

(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin t))

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      indent-tabs-mode nil
  tab-width 2
  standard-indent 2
      custom-file (expand-file-name "custom.el" user-emacs-directory))

(add-hook 'prog-mode-hook
      (lambda ()
    (setq-local indent-tabs-mode nil)
    (setq-local tab-width 2)
    (setq-local standard-indent 2)))

(electric-pair-mode 1)
(show-paren-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)

(use-package vertico
  :demand t
  :config
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion basic)))))

(use-package marginalia
  :demand t
  :config
  (marginalia-mode 1))

(use-package corfu
  :demand t
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config
  (global-corfu-mode 1))

(global-set-key (kbd "C-c y") #'completion-at-point)

(use-package cape
  :demand t
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)
              (add-hook 'completion-at-point-functions #'cape-file nil t))))
;; REMOVIDO: (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
;; Essa linha travava o carregamento do resto do init.el inteiro: `cape-wrap-buster`
;; não existe de verdade no pacote `cape` (os wrappers reais são cape-wrap-silent,
;; cape-wrap-predicate, cape-wrap-nonexclusive etc.), e mesmo que existisse,
;; `eglot-completion-at-point` ainda não está carregado nesse ponto do arquivo
;; (eglot é `:commands`, carregamento adiado) — `advice-add` em símbolo sem
;; função definida dá erro `void-function` na hora, na carga do init.el, e tudo
;; que vem depois no arquivo (eglot, rust-mode, go-mode, markdown-mode, helpful,
;; magit) nunca chegava a ser avaliado. Se quiser resolver completions "grudadas"
;; do eglot no futuro, isso se resolve de outra forma (ex: `eglot-booster` ou
;; simplesmente confiando no cache normal do capf), não com essa advice.

;;; --- Eglot ---
;; Garante que o Eglot seja carregado e configure os hooks manualmente.
(use-package eglot
  :ensure nil
  :demand t
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect 0)
  (eglot-report-progress t) ; mostra "Indexing..." etc na área de eco —
                             ; sem isso a conexão é 100% silenciosa e
                             ; parece que não fez nada enquanto conecta
  :config
  ;; Define os servidores LSP para cada modo.
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode) . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '((go-mode go-ts-mode) . ("gopls")))
  (add-to-list 'eglot-server-programs '((nix-mode nix-ts-mode) . ("nil")))
  (add-to-list 'eglot-server-programs '((lua-mode lua-ts-mode) . ("lua-language-server")))
  (add-to-list 'eglot-server-programs
               '((python-mode python-ts-mode) . ("pyright-langserver" "--stdio"))))

;; Inicia o Eglot automaticamente somente nos modos com servidor configurado
;; e dentro de um projeto que o servidor consegue descobrir.
(defun borba/rust-workspace-p ()
  (and (derived-mode-p 'rust-mode 'rust-ts-mode)
       (locate-dominating-file default-directory "Cargo.toml")))

(defun borba/eglot-ensure-for-supported-mode ()
  (when (memq major-mode
              '(rust-mode rust-ts-mode
                go-mode go-ts-mode
                nix-mode nix-ts-mode
                lua-mode lua-ts-mode
                python-mode python-ts-mode))
    (when (or (not (derived-mode-p 'rust-mode 'rust-ts-mode))
              (borba/rust-workspace-p))
      (eglot-ensure))))

(add-hook 'prog-mode-hook #'borba/eglot-ensure-for-supported-mode)

;;; --- Flymake (para exibir erros) ---
;; Ativa o Flymake em todos os buffers de programação.
(add-hook 'prog-mode-hook #'flymake-mode)

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . prettify-symbols-mode))

(use-package go-mode :mode "\\.go\\'")

(use-package nix-mode :mode "\\.nix\\'")
(use-package lua-mode :mode "\\.lua\\'")

(use-package apheleia
  :config
  (setf (alist-get 'rust-mode apheleia-mode-alist) 'rustfmt
        (alist-get 'rust-ts-mode apheleia-mode-alist) 'rustfmt
        (alist-get 'go-mode apheleia-mode-alist) 'goimports
        (alist-get 'go-ts-mode apheleia-mode-alist) 'goimports
        (alist-get 'nix-mode apheleia-mode-alist) 'alejandra
        (alist-get 'nix-ts-mode apheleia-mode-alist) 'alejandra
        (alist-get 'lua-mode apheleia-mode-alist) 'stylua
        (alist-get 'lua-ts-mode apheleia-mode-alist) 'stylua
        (alist-get 'python-mode apheleia-mode-alist) 'black
        (alist-get 'python-ts-mode apheleia-mode-alist) 'black)
  (setf (alist-get 'rustfmt apheleia-formatters) '("rustfmt" "--emit" "stdout")
        (alist-get 'goimports apheleia-formatters) '("goimports")
        (alist-get 'alejandra apheleia-formatters) '("alejandra" "--quiet" "-")
        (alist-get 'stylua apheleia-formatters)
        '("stylua" "--stdin-filepath" filepath "-")
        (alist-get 'black apheleia-formatters) '("black" "--quiet" "-"))
  (apheleia-global-mode 1))

(use-package markdown-mode
  :mode ("README\\.md\\'" . gfm-mode)
  :mode ("\\.md\\'" . markdown-mode)
  :init (setq markdown-fontify-code-blocks-natively t)
  :hook ((markdown-mode . visual-line-mode)
         (gfm-mode . visual-line-mode)))

(use-package helpful
  :bind (("C-h f" . helpful-callable)
         ("C-h v" . helpful-variable)
         ("C-h k" . helpful-key)))

(use-package magit :bind (("C-c g" . magit-status)))

;; `M-x shell`/`eshell` não interpretam escapes ANSI de cor nem os
;; hyperlinks OSC 8 que o `cargo` emite (o `^[[...`/`^[]8;;...` cru que
;; apareceu na tela). `eat` é um emulador de terminal de verdade — usa
;; `M-x eat` e roda `cargo run` lá dentro.
(use-package eat :bind (("C-c t" . eat)))

;; consult: comandos de busca/navegação (linha, buffer, ripgrep, imenu,
;; histórico do kill-ring) que usam o mesmo vertico/orderless de cima
;; pra filtrar — é o "verbo" que faltava pro vertico já instalado.
(use-package consult
  :bind (("C-s" . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("C-c i" . consult-imenu)
         ("C-c r" . consult-ripgrep)))

;; embark: ações contextuais sobre o que estiver sob o cursor ou
;; selecionado no minibuffer (abrir, matar buffer, exportar um resultado
;; de busca pra um grep-edit editável). embark-consult conecta os dois.
(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)))
(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; which-key: depois de apertar um prefixo (C-c, C-x...) mostra num
;; popup os bindings disponíveis, em vez de precisar decorar tudo.
(use-package which-key
  :demand t
  :config
  (which-key-mode 1))

;; diff-hl: marca na fringe quais linhas mudaram/foram adicionadas/
;; removidas em relação ao git enquanto você edita — complementa o
;; magit, que só mostra isso no status/diff.
(use-package diff-hl
  :demand t
  :config
  (global-diff-hl-mode 1)
  (add-hook 'magit-post-refresh-hook #'diff-hl-magit-post-refresh))

;; hl-todo: destaca TODO/FIXME/HACK/XXX nos comentários com cor, pra não
;; passar batido lendo o código.
(use-package hl-todo
  :demand t
  :config
  (global-hl-todo-mode 1))

;; yaml-mode/toml-mode: highlight e indentação decentes pros arquivos
;; que você mais mexe fora de código de verdade (Cargo.toml, CI yaml,
;; sops secrets.yaml).
(use-package yaml-mode)
(use-package toml-mode)

;; rainbow-delimiters: colore parênteses/colchetes/chaves por nível de
;; aninhamento — ajuda em Rust e principalmente em elisp/nix.
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; avy: pula o cursor pra qualquer palavra/caractere visível na tela com
;; 2-3 teclas, sem contar linhas nem soltar o teclado.
(use-package avy
  :bind (("C-'" . avy-goto-char-timer)))

;; tempel: snippets minimalistas (sintaxe é só lista de Emacs Lisp, sem
;; linguagem de template própria) que entram no mesmo
;; completion-at-point-functions do cape/corfu — não é mais um motor de
;; completion rodando em paralelo.
(use-package tempel
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :init
  (add-hook 'completion-at-point-functions #'tempel-expand))

;; dape: debugger integrado (Debug Adapter Protocol), mesmo ecossistema
;; do eglot. Já vem com config pronta pra Go (usa `delve`, incluso no
;; home.packages de emacs-vanilla.nix). Rust precisa de um adapter
;; separado (`codelldb`, não empacotado aqui por padrão) — quando for
;; configurar, veja `M-x customize-variable RET dape-configs`.
(use-package dape)

(defun borba/format-buffer ()
  "Format the current buffer."
  (interactive)
  (if (bound-and-true-p eglot--managed-mode)
      (eglot-format-buffer)
    (message "No Eglot formatter is active.")))

(global-set-key (kbd "C-c f") #'borba/format-buffer)

(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))

;;; init.el ends here
