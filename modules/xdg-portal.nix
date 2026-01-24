# modules/xdg-portal.nix
{ config, pkgs, lib, ... }:

{
  xdg.portal = {
    enable = true;

    # Backends comuns (gtk cobre a maioria dos casos; hyprland/wlr só quando necessário)
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk     # fallback + GNOME/Hyprland compat
      # xdg-desktop-portal-hyprland  # só se Hyprland for o compositor ativo
      # xdg-desktop-portal-wlr       # para compositores wlroots genéricos
    ];

    # Configuração recomendada para evitar conflitos
    config.common.default = "*";  # usa o portal mais apropriado por app
  };
}
