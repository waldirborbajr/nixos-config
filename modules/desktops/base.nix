{ config, pkgs, ... }:

{
  ############################################
  # Base for all Desktop Environments
  ############################################
  services.xserver.enable = true;
  security.polkit.enable = true;

  # X11 Keyboard layout
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };
  console.keyMap = "br-abnt2";

  # Auto-login handled by user-borba.nix

  # Wayland / XDG Portals
  xdg.portal.enable = true;
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
