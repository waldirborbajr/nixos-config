# modules/xdg-portal.nix
{ config, pkgs, lib, ... }:

{
  xdg.portal = {
    enable = true;

    # GTK portal provides good compatibility for most applications
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk  # Fallback + GNOME/Niri compat
    ];

    # Configuração recomendada para evitar conflitos
    config.common.default = "*";  # usa o portal mais apropriado por app
  };
}
