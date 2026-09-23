# home/home.nix
# Perfil base do home-manager — vale para TODOS os hosts, incluindo o
# macbook (que não tem niri/desktop). O que é só de sessão gráfica
# Linux vive em home/home_niri.nix, que importa este arquivo.
{inputs, ...}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ./identity.nix
    ./shell.nix
    ./editors.nix
    ./cli-and-terminal.nix
  ];

  # Emacs e Neovim desligados por padrão (mesmo padrão de
  # containerTools/development.languages em features.nix) — ative
  # pontualmente na máquina que for usar, descomentando a linha
  # correspondente:
  # editors.emacs.enable = true;
  # editors.neovim.enable = true;   # nasce com nightly = true

  home.stateVersion = "26.05";
}
