# modules/nixos/desktop-niri.nix
#
# Sessão niri: compositor, greetd/regreet, display manager, portal XDG,
# dconf e direnv. Extraído 1:1 de configuration.nix (split cirúrgico,
# sem mudança de comportamento).
{pkgs, ...}: {
  # ==================== NIRI ====================
  programs.niri.enable = true;

  # ==================== GREETD + REGREET ====================
  services.greetd.enable = true;

  programs.regreet = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["mauve"];
        size = "standard";
        tweaks = [];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.symlinkJoin {
        name = "papirus-catppuccin-mauve";
        paths = [
          pkgs.papirus-icon-theme
          (pkgs.catppuccin-papirus-folders.override {
            accent = "mauve";
            flavor = "mocha";
          })
        ];
      };
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Mauve-Cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    cageArgs = ["-s"];

    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = "Catppuccin-Mocha-Standard-Mauve-Dark";
        icon_theme_name = "Papirus-Dark";
        cursor_theme_name = "Catppuccin-Mocha-Mauve-Cursors";
        font_name = "JetBrainsMono Nerd Font 12";
      };

      background = {
        path = "${../../home/configs/wallpapers/login.jpg}";
        fit = "Fill";
      };
    };
  };

  services.displayManager.defaultSession = "niri";

  services.power-profiles-daemon.enable = true;

  programs.dconf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ==================== XDG DESKTOP PORTAL ====================
  # niri não tem DE por trás dele, então precisa de um backend de portal
  # explícito. gnome = screen share/gravação (Brave, Discord, OBS via
  # PipeWire); gtk = file chooser de apps sandboxed/Electron.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gnome xdg-desktop-portal-gtk];
    config.common.default = ["gnome"];
  };
}
