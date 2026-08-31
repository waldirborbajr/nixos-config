;;; onenord-theme.el --- OneNord (Nord + Atom One Dark) theme -*- lexical-binding: t; -*-
;;
;; Mesma paleta usada em home/configs/helix/themes/onenord.toml, portada
;; pra Emacs. Cobre faces básicas, font-lock, diagnostics (flymake/flycheck),
;; diff/magit, e completion (corfu/company/vertico).

(deftheme onenord "OneNord (Nord + Atom One Dark)")

(let ((bg      "#2a303c")
      (bg-alt  "#3B4252")
      (bg-alt2 "#434C5E")
      (bg-alt3 "#4C566A")
      (muted   "#566074")
      (fg      "#bfc5d0")
      (red     "#d57780")
      (orange  "#e39a83")
      (yellow  "#EBCB8B")
      (green   "#A3BE8C")
      (cyan    "#97b7d7")
      (blue    "#81A1C1")
      (magenta "#B48EAD"))

  (custom-theme-set-faces
   'onenord

   ;; núcleo da UI
   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,fg))))
   `(region ((t (:background ,bg-alt2))))
   `(highlight ((t (:background ,bg-alt2))))
   `(fringe ((t (:background ,bg))))
   `(mode-line ((t (:background ,bg-alt :foreground ,fg))))
   `(mode-line-inactive ((t (:background ,bg-alt2 :foreground ,muted))))
   `(minibuffer-prompt ((t (:foreground ,blue :weight bold))))
   `(vertical-border ((t (:foreground ,bg-alt3))))
   `(line-number ((t (:foreground ,muted :background ,bg))))
   `(line-number-current-line ((t (:foreground ,fg :background ,bg-alt2 :weight bold))))
   `(show-paren-match ((t (:background ,bg-alt2 :foreground ,yellow :weight bold))))
   `(show-paren-mismatch ((t (:background ,red :foreground ,bg :weight bold))))
   `(isearch ((t (:background ,yellow :foreground ,bg))))
   `(lazy-highlight ((t (:background ,bg-alt2 :foreground ,fg))))
   `(link ((t (:foreground ,orange :underline t))))
   `(tab-bar ((t (:background ,bg-alt :foreground ,fg))))
   `(tab-bar-tab ((t (:background ,bg-alt2 :foreground ,fg :weight bold))))
   `(tab-bar-tab-inactive ((t (:background ,bg-alt :foreground ,muted))))

   ;; font-lock (sintaxe)
   `(font-lock-comment-face ((t (:foreground ,muted :slant italic))))
   `(font-lock-doc-face ((t (:foreground ,muted :slant italic))))
   `(font-lock-string-face ((t (:foreground ,green))))
   `(font-lock-keyword-face ((t (:foreground ,magenta))))
   `(font-lock-function-name-face ((t (:foreground ,blue))))
   `(font-lock-variable-name-face ((t (:foreground ,red))))
   `(font-lock-type-face ((t (:foreground ,yellow))))
   `(font-lock-constant-face ((t (:foreground ,orange))))
   `(font-lock-builtin-face ((t (:foreground ,cyan))))
   `(font-lock-warning-face ((t (:foreground ,orange :weight bold))))
   `(font-lock-negation-char-face ((t (:foreground ,red))))
   `(font-lock-preprocessor-face ((t (:foreground ,magenta))))
   `(font-lock-property-name-face ((t (:foreground ,red))))

   ;; diagnostics
   `(error ((t (:foreground ,red :weight bold))))
   `(warning ((t (:foreground ,orange :weight bold))))
   `(success ((t (:foreground ,green :weight bold))))
   `(flymake-error ((t (:underline (:style wave :color ,red)))))
   `(flymake-warning ((t (:underline (:style wave :color ,orange)))))
   `(flymake-note ((t (:underline (:style wave :color ,blue)))))
   `(flycheck-error ((t (:underline (:style wave :color ,red)))))
   `(flycheck-warning ((t (:underline (:style wave :color ,orange)))))
   `(flycheck-info ((t (:underline (:style wave :color ,blue)))))

   ;; diff / magit
   `(diff-added ((t (:foreground ,green))))
   `(diff-removed ((t (:foreground ,red))))
   `(diff-changed ((t (:foreground ,orange))))
   `(magit-diff-added ((t (:foreground ,green))))
   `(magit-diff-added-highlight ((t (:foreground ,green :background ,bg-alt2))))
   `(magit-diff-removed ((t (:foreground ,red))))
   `(magit-diff-removed-highlight ((t (:foreground ,red :background ,bg-alt2))))
   `(magit-branch-current ((t (:foreground ,blue :weight bold))))
   `(magit-branch-local ((t (:foreground ,cyan))))
   `(magit-branch-remote ((t (:foreground ,green))))
   `(magit-hash ((t (:foreground ,muted))))

   ;; completion: corfu / company / vertico / orderless
   `(corfu-default ((t (:background ,bg-alt2 :foreground ,fg))))
   `(corfu-current ((t (:background ,bg-alt3 :foreground ,fg))))
   `(corfu-border ((t (:background ,bg-alt3))))
   `(company-tooltip ((t (:background ,bg-alt2 :foreground ,fg))))
   `(company-tooltip-selection ((t (:background ,bg-alt3 :foreground ,fg))))
   `(company-tooltip-common ((t (:foreground ,yellow))))
   `(company-scrollbar-bg ((t (:background ,bg-alt2))))
   `(company-scrollbar-fg ((t (:background ,bg-alt3))))
   `(vertico-current ((t (:background ,bg-alt2))))
   `(orderless-match-face-0 ((t (:foreground ,yellow :weight bold))))
   `(orderless-match-face-1 ((t (:foreground ,cyan :weight bold))))
   `(which-key-key-face ((t (:foreground ,yellow))))
   `(which-key-command-description-face ((t (:foreground ,fg))))))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'onenord)

;;; onenord-theme.el ends here
