{ pkgs, lib, ... }:

{
  ############################################
  # Wayland + GNOME
  ############################################
  services.xserver.enable = true;

  ############################################
  # Display Manager (GDM)
  ############################################
  services.displayManager.gdm = {
    enable = true;
    wayland = true;       # antigo: services.xserver.displayManager.gdm.wayland
    autoSuspend = false;  # antigo: services.xserver.displayManager.gdm.autoSuspend
  };

  ############################################
  # Desktop Manager (GNOME)
  ############################################
  services.desktopManager.gnome.enable = true; # antigo: services.xserver.desktopManager.gnome.enable

  ############################################
  # GNOME performance tweaks
  ############################################
  services.gnome = {
    core-apps.enable = false;    # antigo: services.gnome.core-utilities.enable
    gnome-keyring.enable = true;
  };

  ############################################
  # Wayland Environment Variables
  ############################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  ############################################
  # XDG Portals
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # Auto-login
  ############################################
  services.displayManager.autoLogin = {
    enable = true;      # antigo: services.xserver.displayManager.autoLogin
    user = "borba";
  };

  ############################################
  # Remove TTY concorrente
  ############################################
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # Journald logs limits
  ############################################
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=50M
  '';
  
  ############################################
  # Network
  ############################################
  systemd.services.NetworkManager-wait-online.enable = false;
}
