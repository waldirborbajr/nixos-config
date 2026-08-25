# hosts/macbook/home.nix
# MacBook M2 físico — macOS (aarch64-darwin), home-manager standalone.
#
# Isso NÃO gerencia o sistema operacional (sem nix-darwin) — só instala
# programas e aplica os dotfiles que já existem no flake, via
# `home-manager switch --flake .#borba@macbook`.
#
# Reaproveita os módulos de home/modules/ que não dependem de Wayland/Linux.
# `desktop.nix` (niri/waybar/mako) fica de fora de propósito.
{
  pkgs,
  lib,
  inputs,
  ...
}: let
  username = "borba";
in {
  imports = [
    inputs.nix-index-database.homeModules.nix-index

    ../../home/modules/identity.nix
    ../../home/modules/shell.nix
    ../../home/modules/editors.nix
    ../../home/modules/cli-and-terminal.nix
  ];

  # identity.nix assume /home/${username} (Linux) — no macOS o home fica
  # em /Users/${username}. mkForce porque identity.nix atribui direto,
  # sem mkDefault.
  home.homeDirectory = lib.mkForce "/Users/${username}";

  home.stateVersion = "26.05";

  # ==================== FIRST-ACTIVATION OVERWRITE ====================
  # Este Mac já tinha dotfiles soltos (não geridos pelo Nix), o que trava
  # `home-manager switch` na primeira ativação (o Nix se recusa a
  # sobrescrever arquivos que não criou). Em vez de force = true (que
  # descarta o conteúdo anterior sem cópia nenhuma), usamos o mesmo
  # mecanismo dos hosts NixOS (ver `home-manager.backupFileExtension` em
  # modules/nixos/users-and-home.nix): qualquer arquivo pré-existente no
  # caminho de um `home.file`/`xdg.configFile` gerenciado é renomeado para
  # "<arquivo>.hm-backup" em vez de apagado. Escopo só deste host — não
  # afeta mac2011/dell1564/VMs.
  home.backupFileExtension = "hm-backup";

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  # Só afeta o MacBook M2 físico — não impacta mac2011, dell1564, macutm
  # nem macvmf. Adicione aqui o que só faz sentido nesta máquina.
  #
  # `neovim` NÃO mora mais aqui — foi pra home/modules/editors.nix (ver
  # comentário lá) porque git.core.editor="nvim" e os dotfiles do zsh
  # (aliases/functions) que esperam esse binário são compartilhados por
  # TODOS os hosts, não só este.
  home.packages = with pkgs; [
    # rapidraw
    darktable
  ];
}
