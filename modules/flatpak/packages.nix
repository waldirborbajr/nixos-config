# modules/flatpak/packages.nix
{ config, pkgs, ... }:

let
  desired = [
    # Browsers
    "org.mozilla.firefox"
    "com.brave.Browser"

    # Development / IDE
    "com.visualstudio.code"

    # Communication
    "com.discordapp.Discord"
    "me.proton.Mail"

    # Knowledge / Media
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

    # Downloads / Torrents
    "com.transmissionbt.Transmission"

    # Screen Shot
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
  system.userActivationScripts.flatpakInstall = {
    text = ''
      # Ensure Flathub remote (redundant but safe)
      ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

      installed=$(${pkgs.flatpak}/bin/flatpak list --app --columns=application)

      for app in ${builtins.toString desired}; do
        if ! echo "$installed" | grep -q -F "$app"; then
          echo "Installing missing Flatpak: $app"
          ${pkgs.flatpak}/bin/flatpak install -y --noninteractive flathub "$app" || true
        fi
      done

      # Optional: update all
      echo "Updating Flatpaks..."
      ${pkgs.flatpak}/bin/flatpak update -y --noninteractive || true

      # Clean up unused runtimes
      ${pkgs.flatpak}/bin/flatpak uninstall --unused -y || true

      # Uncomment below if you want strict mode (remove apps not in list)
      # for app in $installed; do
      #   if ! echo "${builtins.toString desired}" | grep -q -F "$app"; then
      #     echo "Removing unmanaged: $app"
      #     ${pkgs.flatpak}/bin/flatpak uninstall -y --noninteractive "$app" || true
      #   fi
      # done
    '';
  };
}
