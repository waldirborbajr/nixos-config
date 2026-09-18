# home/default.nix
# Home Manager configuration for user borba — Fase 3.
#
# Dotfile contents live inside the flake (home/configs/). No external
# ~/dotfiles dependency for managed programs.
#
# Split cirúrgico em home/modules/ (ver README.md e REFACTOR-NOTES.md) —
# este arquivo é só o índice; cada módulo mapeia 1:1 pra um tópico.
{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ./modules/identity.nix
    ./modules/shell.nix
    ./modules/editors.nix
    ./modules/emacs-vanilla.nix
    ./modules/cli-and-terminal.nix
    ./modules/desktop.nix
  ];

  # Emacs e Neovim desligados por padrão (mesmo padrão de
  # containerTools/development.languages) — ative pontualmente na
  # máquina que for usar, descomentando a linha correspondente:
  # editors.emacs.enable = true;
  # editors.neovim.enable = true;   # nasce com nightly = true

  home.stateVersion = "26.05";
}