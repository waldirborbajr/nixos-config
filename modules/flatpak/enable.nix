# modules/flatpak/enable.nix
{ pkgs, ... }:
{
  services.flatpak.enable = true;

  # Add Flathub (system-wide, survives rebuilds)
  services.flatpak.remotes = lib.mkBefore [  # mkBefore so it can be overridden if needed
    {
      name = "flathub";
      location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    }
  ];

  # XDG portal is required for Flatpak apps to access host resources properly
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Optional: if you use GNOME/KDE and want graphical Flatpak updates/installs
  # environment.systemPackages = [ pkgs.gnome.gnome-software pkgs.gnome.gnome-software ];
}
