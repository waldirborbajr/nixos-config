;;; packages.el -*- no-byte-compile: t; -*-

;; Revisei init.el e config.el: tudo que é referenciado (evil, company,
;; vertico, lsp-mode, lsp-pyright, lsp-go, rustic, nix-mode, projectile,
;; pyvenv, etc.) já vem embutido nos módulos do Doom habilitados no init.el
;; (:completion company/vertico, :tools lsp, :lang go/python/rust/nix/lua...).
;; `pyvenv`, em particular, já faz parte do pacote padrão do módulo
;; `:lang python`, então o `use-package! pyvenv` do config.el não precisa de
;; nada extra aqui.
;;
;; Esse arquivo fica vazio até você precisar de algo que NÃO seja puxado
;; por um módulo do Doom (um pacote do MELU/GitHub à parte, um fork, etc.).
;; Exemplos de uso, se/quando precisar:
;;
;; (package! algum-pacote)
;; (package! outro-pacote :recipe (:host github :repo "usuario/repo"))
;; (package! pacote-do-doom :disable t) ; desativa um pacote que um módulo traria
