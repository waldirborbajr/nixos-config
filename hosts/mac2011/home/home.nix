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
  # Vindo de hosts/macbook/home/home.nix — darktable é exclusivo do mac2011.
  home.packages = with pkgs; [
    darktable
    gnome-text-editor
  ];
}
