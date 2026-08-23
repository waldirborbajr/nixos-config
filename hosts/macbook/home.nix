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

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  # Só afeta o MacBook M2 físico — não impacta mac2011, dell1564, macutm
  # nem macvmf. Adicione aqui o que só faz sentido nesta máquina.
  home.packages = with pkgs; [
    # ex.: rectangle
  ];
}
