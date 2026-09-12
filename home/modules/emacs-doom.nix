{
  inputs,
  pkgs,
  lib,
  ...
}: let
  # emacs-pgtk = build nativa GTK (ícones, transparência, melhor suporte a
  # Wayland/X11), vinda do overlay nix-community/emacs-overlay aplicado
  # globalmente em modules/nixos/users-and-home.nix (nixpkgs.overlays) —
  # o emacs-overlay NÃO expõe essas variantes como saída de flake
  # (`packages.${system}.emacs-pgtk` não existe), só via overlay em cima do
  # pkgs normal. Nome do atributo mudou de emacsPgtk (camelCase, deprecado)
  # pra emacs-pgtk (kebab-case) — nixpkgs ganhou um emacs-pgtk próprio e o
  # overlay renomeou o dele pra não colidir. Outras opções que o mesmo
  # overlay injeta em pkgs, se quiser trocar depois: pkgs.emacs-unstable,
  # pkgs.emacs-git, pkgs.emacs-pgtk-native-comp (compilação nativa, build
  # mais lento porém mais rápido em uso).
  doomEmacs = pkgs.emacs-pgtk;

  # Gramáticas nativas do treesit (Emacs 29+) usadas por go/python/nix
  # (rust não usa mais +tree-sitter, ver init.el). Calculado uma vez só
  # e reaproveitado abaixo — antes esse mesmo `with-grammars` estava
  # duplicado (uma vez em home.packages, outra em sessionVariables) e
  # podia divergir.
  treesitGrammars = pkgs.emacsPackages.treesit-grammars.with-grammars (
    grammars:
      with grammars; [
        tree-sitter-rust
        tree-sitter-go
        tree-sitter-python
        tree-sitter-nix
      ]
  );

  # LSP servers e formatters usados pelo Doom init.el/config.el gerados antes.
  # Deixe comentado se preferir depender só dos devshells/ + direnv (o config.el
  # já ativa `direnv-mode`, então dentro de um projeto com `.envrc` o Doom pega
  # os binários do devshell automaticamente).
  doomExtraPackages = with pkgs; [
    # rust-analyzer
    # gopls
    # lua-language-server
    # nixd
    # pyright
    # alejandra   # já usado pelo nix-mode do doom-config.el

    aspell
    aspellDicts.en # :checkers spell precisa de um spellchecker de verdade no PATH

    treesitGrammars
  ];
in {
  imports = [inputs.nix-doom-emacs-unstraightened.hmModule];

  programs.doom-emacs = {
    enable = true;
    doomDir = ../configs/doom; # espera init.el / config.el / packages.el aqui
    emacs = doomEmacs;
  };

  home.packages = doomExtraPackages;

  # ANTES: path do grammar ia via `home.sessionVariables` (env var lida em
  # config.el com `getenv`). Isso é frágil pra um Emacs gráfico disparado
  # direto pelo niri (exec/keybinding), que NÃO passa por um shell de
  # login/interativo e portanto não herda variáveis exportadas via
  # home-manager — resultado: `treesit-extra-load-path` ficava vazio e a
  # gramática nunca era encontrada.
  #
  # AGORA: o path do Nix store fica embutido direto num arquivo elisp
  # gerado pelo home-manager, que config.el carrega incondicionalmente
  # (sem depender de nenhuma env var estar presente no processo do Emacs).
  home.file.".config/doom/nix-treesit-grammars.el".text = ''
    ;; Gerado por home/modules/emacs-doom.nix — não edite à mão.
    (add-to-list 'treesit-extra-load-path "${treesitGrammars}/lib")
  '';

  # O nix-doom-emacs-unstraightened provavelmente já usa `--init-directory`
  # (Emacs 29+) apontando pro doomDir empacotado, o que ignora ~/.emacs por
  # conta própria — mas manter esse guard aqui também não custa nada e evita
  # surpresa se isso mudar. Mesmo motivo/mesmo código do emacs-vanilla.nix:
  # `~/.emacs`/`~/.emacs.el` têm prioridade sobre qualquer init gerenciado
  # pelo Nix e um leftover de instalação manual anterior é ignorado em
  # silêncio, sem erro nenhum.
  home.activation.removeLegacyEmacsInit = lib.hm.dag.entryBefore ["writeBoundary"] ''
    for f in "$HOME/.emacs" "$HOME/.emacs.el"; do
      if [ -e "$f" ] && [ ! -L "$f" ]; then
        $DRY_RUN_CMD mv $VERBOSE_ARG "$f" "$f.pre-nix-backup"
      fi
    done
  '';
}
