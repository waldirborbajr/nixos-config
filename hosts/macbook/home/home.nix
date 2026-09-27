# hosts/macbook/home/home.nix
# MacBook M2 físico — macOS (aarch64-darwin), home-manager standalone.
#
# Isso NÃO gerencia o sistema operacional (sem nix-darwin) — só instala
# programas e aplica os dotfiles que já existem no flake, via
# `home-manager switch --flake .#borba@macbook`.
{
  pkgs,
  lib,
  ...
}: {
  imports = [../../../home/profiles/base.nix];

  # identity.nix (dentro de home/profiles/base.nix) assume /home/borba
  # (Linux) — no macOS o home fica em /Users/borba. mkForce porque
  # identity.nix atribui direto, sem mkDefault.
  home.homeDirectory = lib.mkForce "/Users/borba";

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  home.packages = with pkgs; [
    darktable
  ];
}
