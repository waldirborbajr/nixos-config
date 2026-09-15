{pkgs, ...}: let
  configs = ../configs;

  myEmacs = pkgs.emacs.pkgs.withPackages (epkgs: [
    # major-modes que o Emacs core não traz
    epkgs.nix-mode
    epkgs.lua-mode
    epkgs.go-mode # fallback caso não use go-ts-mode
    epkgs.rust-mode # fallback caso não use rust-ts-mode

    # sua stack de eglot
    epkgs.treesit-auto

    # integra com seus devshells `nix develop`
    epkgs.envrc

    # opcional, combina com o resto do repo
    epkgs.magit

    # terminal real (não shell-mode/eshell) — só assim escapes ANSI de
    # cor E hyperlinks OSC 8 (tipo os do `cargo`) renderizam certo
    epkgs.eat

    # busca/navegação (usa o mesmo vertico/orderless de cima) + ações
    # contextuais sobre o resultado
    epkgs.consult
    epkgs.embark
    epkgs.embark-consult

    # mostra os bindings disponíveis depois de um prefixo (C-c, C-x...)
    epkgs.which-key

    # sinaliza mudanças de git na fringe enquanto edita (complementa o magit)
    epkgs.diff-hl

    # destaca TODO/FIXME/HACK/XXX nos comentários
    epkgs.hl-todo

    # highlight/indentação pra Cargo.toml, CI yaml, sops secrets.yaml etc.
    epkgs.yaml-mode
    epkgs.toml-mode

    # colore parênteses/chaves por nível de aninhamento
    epkgs.rainbow-delimiters

    # pula o cursor pra qualquer ponto visível na tela com poucas teclas
    epkgs.avy

    # snippets minimalistas que já usam completion-at-point (mesmo
    # pipeline do cape/corfu, sem motor de template separado)
    epkgs.tempel

    # debugger (Debug Adapter Protocol) integrado ao eglot
    epkgs.dape

    # usados pelo init.el atual (use-package), fora do que já tínhamos
    # `use-package` precisa estar no mesmo conjunto do Emacs para que o
    # bootstrap do init.el funcione; sem ele o `eglot` não inicia sozinho.
    epkgs.use-package
    epkgs.catppuccin-theme
    epkgs.vertico
    epkgs.orderless
    epkgs.marginalia
    epkgs.cape
    epkgs.helpful
    epkgs.markdown-mode
    epkgs.apheleia

    # eglot só fornece `completion-at-point-functions`, sem UI nenhuma —
    # sem isso não existe popup de autocomplete em NENHUMA linguagem
    # (rust/go/nix/python/lua sofrem igual, não é específico do Rust).
    epkgs.corfu
    epkgs.corfu-terminal # fallback pro corfu quando roda `emacs -nw` (sem child-frame)
    epkgs.popon # dependência do corfu-terminal
  ]);

  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-grammars (
    grammars:
      with grammars; [
        tree-sitter-nix
        tree-sitter-lua
        tree-sitter-go
        tree-sitter-python
      ]
  );
in {
  home.packages = [
    myEmacs
    treesitGrammars

    # Sem `.envrc`/devshell (ex: pastas soltas tipo aoc-tasks, sem flake
    # próprio), o `direnv`/`envrc-mode` não injeta nada no PATH e o eglot
    # não acha o LSP — falha calada dentro do hook `eglot-ensure`, sem
    # avisar, e sem LSP não tem autocomplete nem diagnóstico de erro.
    # Instalando global aqui funciona como fallback; projetos com devshell
    # continuam pegando a versão pinada de lá via direnv normalmente.
    pkgs.rustfmt
    pkgs.gopls
    pkgs.go
    pkgs.gotools
    pkgs.lua-language-server
    pkgs.stylua
    pkgs.nixd
    pkgs.nil # init.el chama o server do nix pelo nome "nil", não "nixd"
    pkgs.pyright
    pkgs.black
    pkgs.alejandra
  ];

  xdg.configFile."emacs" = {
    source = "${configs}/emacs";
    recursive = true;
  };

  # grammars pré-compiladas pelo nix — sem precisar de gcc/libtool em runtime.
  # referenciado no init.el via:
  #   (setq treesit-extra-load-path
  #         (list "${treesitGrammars}/lib"))
  home.sessionVariables = {
    EMACS_TREESIT_GRAMMAR_PATH = "${treesitGrammars}/lib";
  };

  # ---------------------------------------------------------------------
  # Numa instalação nova, `~/.emacs`/`~/.emacs.el` têm prioridade MAIOR que
  # `~/.config/emacs/init.el` na busca do Emacs — se algum arquivo desses
  # existir (de uma instalação manual anterior, ou de outra máquina restaurada
  # via backup/dotfiles antigos), o Emacs ignora silenciosamente TUDO que
  # gerenciamos aqui, sem erro nenhum. Foi exatamente isso que consumiu uma
  # sessão inteira de debug. Move qualquer um desses de lado (se não for já
  # um symlink nosso) antes de cada ativação.
  # ---------------------------------------------------------------------
  # home.activation.removeLegacyEmacsInit = lib.hm.dag.entryBefore ["writeBoundary"] ''
  #   for f in "$HOME/.emacs" "$HOME/.emacs.el"; do
  #     if [ -e "$f" ] && [ ! -L "$f" ]; then
  #       $DRY_RUN_CMD mv $VERBOSE_ARG "$f" "$f.pre-nix-backup"
  #     fi
  #   done
  # '';
}
