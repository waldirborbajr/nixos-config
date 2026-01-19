{ config, pkgs, ... }:

{
  ############################################
  # Virt-manager + Wayland integration
  ############################################

  environment.systemPackages = with pkgs; [
    spice
    spice-gtk
    spice-protocol
    virt-viewer
  ];

  ############################################
  # Wayland clipboard support
  ############################################
  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  ############################################
  # XDG portal (clipboard / screen)
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
}
