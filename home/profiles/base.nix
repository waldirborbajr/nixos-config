# home/profiles/base.nix
#
# Perfil base do home-manager — vale para TODOS os hosts, incluindo o
# macbook (que não tem niri/desktop). A camada gráfica Linux vive em
# home/profiles/desktop.nix, que importa este arquivo.
#
# Igual ao base.nix do ulyssecrn: tudo que é comum a qualquer host vive
# DIRETO aqui (identidade, git, pacotes utilitários sem config própria)
# — só o que tem módulo/config dedicado (shell, editores, terminal,
# btop, tmux) continua em arquivo separado e entra via imports.
{
  inputs,
  pkgs,
  ...
}: let
  configs = ../configs;
in {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ../modules/shell.nix
    ../modules/editors.nix
    ../modules/cli-and-terminal.nix
    ../modules/btop.nix
    ../modules/tmux.nix
  ];

  # ── Identidade ──────────────────────────────────────────────────────
  # Antes era home/identity.nix (arquivo próprio); o ulyssecrn não tem
  # um identity.nix separado — fica direto no base.nix.
  home.username = "borba";
  home.homeDirectory = "/home/borba";

  xdg.enable = true;

  # nix-index-database: índice pré-pronto, atualizado semanalmente, pra
  # `command-not-found` e `nix-locate` funcionarem na hora, sem rodar
  # `nix-index` à mão em cada host. `comma` deixa rodar um comando de um
  # pacote que você não instalou ainda: `, cowsay`.
  programs.nix-index-database.comma.enable = true;

  # ── Git ─────────────────────────────────────────────────────────────
  # Só liga o programa (garante o pacote `git` no PATH); a config em si
  # (user, core, pull, delta etc.) vem inteira do link "git" abaixo, não
  # de programs.git.settings/delta (que brigaria com o arquivo linkado).
  # Diferente do ulyssecrn (que já usa programs.git.settings nativo) —
  # git ainda não entrou na leva de migração pra config nativa (essa foi
  # só shell/btop/tmux); fica pra quando você decidir.
  programs.git.enable = true;
  xdg.configFile."git" = {
    source = "${configs}/git";
    recursive = true;
  };

  # ── Pacotes comuns (sem config própria) ──────────────────────────────
  # O que tem dotfile/config dedicado (fastfetch, atuin, bat, delta,
  # jujutsu, lazygit, oh-my-posh, os terminais) fica em
  # home/modules/cli-and-terminal.nix, pacote e config juntos — mover só
  # o pacote pra cá deixaria a config órfã. Aqui só o que não tem
  # arquivo de config nenhum, igual ao home.packages do base.nix do
  # ulyssecrn (eza/nnn/nmap/tree/gawk/fastfetch/wget/gh/arquivadores/
  # sensores lá; aqui é a lista equivalente com o que você usa).
  home.packages = with pkgs; [
    gh # GitHub CLI
    gh-dash # GitHub CLI TUI dashboard
    asciinema
    asciinema-agg
    asciinema-scenario
    mupdf # lightweight PDF renderer/tools
    kdlfmt # formata os .kdl do niri/waybar
    unzip
    zip
    p7zip
    xarchiver # GUI leve pra zip/7z/tar/rar
    ffmpeg
    marksman # markdown LSP (sem referência no languages.toml do Helix hoje)
  ];

  # Emacs e Neovim desligados por padrão — ative pontualmente na máquina
  # que for usar, descomentando a linha correspondente:
  # editors.emacs.enable = true;
  # editors.neovim.enable = true;   # nasce com nightly = true

  home.stateVersion = "26.05";
}
