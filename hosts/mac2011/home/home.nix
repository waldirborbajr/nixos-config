# hosts/mac2011/home/home.nix
{pkgs, ...}: {
  imports = [
    ../../../home/profiles/base.nix
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
    # ../../../home/modules/herdr.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  # darktable: vindo de hosts/macbook/home/home.nix.
  # brave/vlc: vindo de home/profiles/desktop.nix + system/profiles/x86/desktop.nix
  # (estavam duplicados nos dois — agora só existem aqui, exclusivos do mac2011).
  home.packages = with pkgs; [
    darktable
    gnome-text-editor
    brave
    vlc
  ];
}
