{ pkgs, ... }:

{
  ############################################
  # Wayland + GNOME
  ############################################
  services.xserver.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    # Evita atrasos esperando sessão anterior
    autoSuspend = false;
  };

  services.xserver.desktopManager.gnome.enable = true;

  # Login automático
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  # Remove TTY concorrente
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

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
  # GNOME performance tweaks
  ############################################
  # Não esperar network-online no boot gráfico
  systemd.services.NetworkManager-wait-online.enable = false;

  # Menos serviços inúteis no desktop
  services.gnome = {
    core-utilities.enable = false;
    gnome-keyring.enable = true;
  };

  # Reduz overhead de logs em desktop
  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=50M
  '';
}
