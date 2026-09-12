{
  pkgs,
  lib,
  ...
}: let
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

    # usados pelo init.el atual (use-package), fora do que já tínhamos
    epkgs.catppuccin-theme
    epkgs.vertico
    epkgs.orderless
    epkgs.marginalia
    epkgs.cape
    epkgs.helpful
    epkgs.markdown-mode

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
        tree-sitter-rust
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
    pkgs.rust-analyzer
    pkgs.gopls
    pkgs.lua-language-server
    pkgs.nixd
    pkgs.nil # init.el chama o server do nix pelo nome "nil", não "nixd"
    pkgs.pyright
  ];

  xdg.configFile."emacs" = {
    source = "${configs}/emacs";
    recursive = true;
  };
  # REMOVIDO: home.file.".emacs.d/init.el".source = ...
  # Criar ~/.emacs.d/init.el faz o Emacs tratar ~/.emacs.d/ como o
  # user-emacs-directory (tem prioridade sobre ~/.config/emacs/ na busca
  # padrão do Emacs) — só que apenas o init.el foi linkado pra lá, não o
  # early-init.el, que só existe em ~/.config/emacs/. Resultado: o
  # early-init.el (package-enable-at-startup nil, frame-alist, etc.) para
  # de carregar silenciosamente. xdg.configFile."emacs" acima já linka o
  # diretório inteiro corretamente — não precisa de fallback nenhum.

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
  home.activation.removeLegacyEmacsInit = lib.hm.dag.entryBefore ["writeBoundary"] ''
    for f in "$HOME/.emacs" "$HOME/.emacs.el"; do
      if [ -e "$f" ] && [ ! -L "$f" ]; then
        $DRY_RUN_CMD mv $VERBOSE_ARG "$f" "$f.pre-nix-backup"
      fi
    done
  '';
}
