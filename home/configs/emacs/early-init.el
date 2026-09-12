;;; early-init.el --- Early startup configuration -*- lexical-binding: t; -*-

(setq gc-cons-threshold (* 256 1024 1024)
      read-process-output-max (* 4 1024 1024)
      package-enable-at-startup nil
      frame-inhibit-implied-resize t
      inhibit-startup-screen t
      inhibit-splash-screen t)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

;;; early-init.el ends here
