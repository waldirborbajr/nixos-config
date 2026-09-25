# home/profiles/base.nix
# Perfil base do home-manager — vale para TODOS os hosts, incluindo o
# macbook (que não tem niri/desktop). A camada gráfica Linux vive em
# home/profiles/desktop.nix, que importa este arquivo.
{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ../modules/identity.nix
    ../modules/shell.nix
    ../modules/editors.nix
    ../modules/cli-and-terminal.nix
    ../modules/btop.nix
    ../modules/tmux.nix
  ];

  # Emacs e Neovim desligados por padrão — ative pontualmente na máquina
  # que for usar, descomentando a linha correspondente:
  # editors.emacs.enable = true;
  # editors.neovim.enable = true;   # nasce com nightly = true

  home.stateVersion = "26.05";
}
