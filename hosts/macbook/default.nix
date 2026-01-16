{ ... }:

{
  networking.hostName = "macbook";

  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  services.xserver.xkb.layout = "us";
}
