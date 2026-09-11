;;; early-init.el -*- lexical-binding: t; -*-

;; Evita GC excessivo e chamadas de IO caras durante o startup
(setq gc-cons-threshold (* 64 1000 1000)
      read-process-output-max (* 1024 1024)   ; ajuda LSPs como rust-analyzer/gopls
      package-enable-at-startup nil)

;; UI mínima antes mesmo do frame renderizar (evita "flash" de toolbar/menu)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

(setq frame-inhibit-implied-resize t
      inhibit-splash-screen t)
