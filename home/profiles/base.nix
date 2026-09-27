# home/profiles/base.nix
#
# Perfil base do home-manager — vale para TODOS os hosts, incluindo o
# macbook (que não tem niri/desktop). A camada gráfica Linux vive em
# home/profiles/desktop.nix, que importa este arquivo.
#
# Igual ao base.nix do ulyssecrn: tudo que é comum a qualquer host vive
# DIRETO aqui (identidade, pacotes utilitários sem config própria) —
# o que tem módulo/config dedicado entra via imports.
{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ../modules/shell.nix
    ../modules/editors.nix
    ../modules/cli-and-terminal.nix
    ../modules/alacritty.nix
    ../modules/btop.nix
    ../modules/tmux.nix
    ../modules/ripgrep.nix
    ../modules/fastfetch.nix
    ../modules/yazi.nix
    ../modules/zsh.nix
    ../modules/oh-my-posh.nix
    ../modules/git.nix
    ../modules/atuin.nix
    ../modules/jujutsu.nix
  ];

  # ── Identidade ──────────────────────────────────────────────────────
  home.username = "borba";
  home.homeDirectory = "/home/borba";

  xdg.enable = true;

  # nix-index-database + comma
  programs.nix-index-database.comma.enable = true;

  # ── Git ─────────────────────────────────────────────────────────────
  # ÚNICO dono: home/modules/git.nix
  # (home.file.".config/git/config" + packages: git, delta, gh, gh-dash, lazygit, …)
  # NÃO usar programs.git nem xdg.configFile."git" aqui.

  # ── Pacotes comuns (sem config própria) ──────────────────────────────
  # gh / gh-dash / delta / git → home/modules/git.nix
  home.packages = with pkgs; [
    asciinema
    asciinema-agg
    asciinema-scenario
    mupdf
    kdlfmt
    unzip
    unrar
    zip
    p7zip
    xarchiver
    ffmpeg
    marksman
  ];

  # editors.emacs.enable = true;
  # editors.neovim.enable = true;

  home.stateVersion = "26.05";
}
