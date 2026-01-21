# modules/flatpak/packages.nix
{ config, pkgs, lib, ... }:

let
  desired = [
    # Browsers
    "org.mozilla.firefox"
    "com.brave.Browser"

    # Development
    "com.visualstudio.code"

    # Communication
    "com.discordapp.Discord"
    "me.proton.Mail"

    # Knowledge
    "md.obsidian.Obsidian"

    # Utilities
    "com.anydesk.Anydesk"

    # Media / Graphics
    "org.gimp.GIMP"
    "org.inkscape.Inkscape"
    "org.audacityteam.Audacity"
    "fr.handbrake.ghb"
    "io.mpv.Mpv"
    "org.imagemagick.ImageMagick"

    # Downloads
    "com.transmissionbt.Transmission"

    # Screenshot
    "be.alexandervanhee.gradia"
    "org.flameshot.Flameshot"

#    "org.mozilla.firefoxdeveloperedition"
#    "org.chromium.Chromium"
#    "com.vivaldi.Vivaldi"
#    "com.google.AndroidStudio"
#    "com.obsproject.Studio"
#    "com.ticktick.TickTick"
#    "com.calibre_ebook.calibre"
#    "org.libreoffice.LibreOffice"

  ];
in
{
  # Make sure Flatpak is enabled (redundant if already in enable.nix, but safe)
  services.flatpak.enable = true;

  system.userActivationScripts.installFlatpaks = {
    # text = the bash script to run for each user on activation
    text = ''
      # Add Flathub if missing (redundant with remotes= but harmless)
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      # Get currently installed apps (only apps, not runtimes)
      installed=$(${pkgs.flatpak}/bin/flatpak list --app --columns=application)

      # Install missing ones
      for app in ${lib.escapeShellArgs desired}; do
        if ! echo "$installed" | grep -q -F "$app"; then
          echo "Installing Flatpak: $app"
          ${pkgs.flatpak}/bin/flatpak install -y --noninteractive flathub "$app" || true
        fi
      done

      # Optional: update everything (can take time, comment out if unwanted)
      echo "Updating all Flatpaks..."
      ${pkgs.flatpak}/bin/flatpak update -y --noninteractive || true

      # Optional: remove unused runtimes/deps
      ${pkgs.flatpak}/bin/flatpak uninstall --unused -y || true

      # Optional strict mode: remove apps not in your list
      # for app in $installed; do
      #   if ! echo "${lib.concatStringsSep " " desired}" | grep -q -F "$app"; then
      #     echo "Removing unmanaged Flatpak: $app"
      #     ${pkgs.flatpak}/bin/flatpak uninstall -y --noninteractive "$app" || true
      #   fi
      # done
    '';
  };
}

