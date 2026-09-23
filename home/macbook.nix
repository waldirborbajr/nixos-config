# home/macbook.nix
# MacBook M2 físico — macOS (aarch64-darwin), home-manager standalone.
#
# Isso NÃO gerencia o sistema operacional (sem nix-darwin) — só instala
# programas e aplica os dotfiles que já existem no flake, via
# `home-manager switch --flake .#borba@macbook`.
#
# Importa o perfil base (home.nix: identity/shell/editors/cli-and-terminal).
# `home_niri.nix` (niri/waybar/mako/emacs-vanilla) fica de fora de propósito —
# sem Wayland/Linux aqui.
{
  pkgs,
  lib,
  ...
}: let
  common = import ../global_constants.nix;
in {
  imports = [./home.nix];

  # identity.nix (dentro de home.nix) assume /home/${username} (Linux) —
  # no macOS o home fica em /Users/${username}. mkForce porque
  # identity.nix atribui direto, sem mkDefault.
  home.homeDirectory = lib.mkForce "/Users/${common.username}";

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  # Só afeta o MacBook M2 físico — não impacta mac2011, dell1564, macutm
  # nem macvmf. Adicione aqui o que só faz sentido nesta máquina.
  #
  # `neovim` NÃO mora aqui — foi pra home/editors.nix (ver comentário lá)
  # porque git.core.editor="nvim" e os dotfiles do zsh (aliases/functions)
  # que esperam esse binário são compartilhados por TODOS os hosts, não
  # só este.
  home.packages = with pkgs; [
    # rapidraw
    darktable
  ];
}
