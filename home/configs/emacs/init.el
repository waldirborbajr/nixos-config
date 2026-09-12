;;; init.el --- Development environment -*- lexical-binding: t; -*-

(setq gc-cons-threshold (* 256 1024 1024)
      read-process-output-max (* 4 1024 1024)
      process-adaptive-read-buffering nil)

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

(set-face-attribute 'default nil :family "JetBrainsMono Nerd Font" :height 120)
(unless (find-font (font-spec :name "JetBrainsMono Nerd Font"))
  (set-face-attribute 'default nil :family "JetBrains Mono"))

(use-package catppuccin-theme
  :config
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin t))

(require 'uniquify)
(setq uniquify-buffer-name-style 'forward
      indent-tabs-mode nil
      tab-width 4
      custom-file (expand-file-name "custom.el" user-emacs-directory))

(electric-pair-mode 1)
(show-paren-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)

(use-package vertico :init (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion basic)))))

(use-package marginalia :init (marginalia-mode 1))

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.15)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :bind ("C-c y" . completion-at-point) ; disparo manual — M-TAB costuma ser
                                          ; capturado pelo WM (niri usa
                                          ; Alt+Tab pra trocar de janela)
  :init
  (global-corfu-mode 1))

(use-package cape
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (add-hook 'completion-at-point-functions #'cape-dabbrev nil t)
              (add-hook 'completion-at-point-functions #'cape-file nil t))))

(use-package eglot
  :ensure nil
  :custom
  (eglot-autoshutdown t)
  (eglot-sync-connect 0)
  (eglot-report-progress t) ; mostra "Indexing..." etc na área de eco —
                             ; sem isso a conexão é 100% silenciosa e
                             ; parece que não fez nada enquanto conecta
  :config
  (add-to-list 'eglot-server-programs '((rust-mode rust-ts-mode) . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '(go-mode . ("gopls")))
  (add-to-list 'eglot-server-programs '((nix-mode nix-ts-mode) . ("nil")))
  (add-to-list 'eglot-server-programs '(lua-mode . ("lua-language-server")))
  :hook
  ((rust-mode rust-ts-mode go-mode nix-mode nix-ts-mode lua-mode) . eglot-ensure))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . prettify-symbols-mode))

(when (fboundp 'rust-ts-mode)
  (add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode)))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (before-save . gofmt-before-save))

(use-package nix-mode :mode "\\.nix\\'")
(use-package lua-mode :mode "\\.lua\\'")

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

(defun borba/format-buffer ()
  "Format the current buffer."
  (interactive)
  (if (bound-and-true-p eglot--managed-mode)
      (eglot-format-buffer)
    (message "No Eglot formatter is active.")))

(global-set-key (kbd "C-c f") #'borba/format-buffer)

(when (file-exists-p custom-file)
  (load custom-file nil 'nomessage))
