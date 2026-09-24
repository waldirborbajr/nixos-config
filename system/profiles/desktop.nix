# system/profiles/desktop.nix
#
# Sessão gráfica niri, completa: compositor, greetd/regreet, portal XDG,
# áudio (PipeWire) e os quirks de hardware (nix-ld, bluetooth) que valem
# pra qualquer host com sessão gráfica. Junta o que antes eram
# modules/desktop_niri.nix + audio.nix + hardware_quirks.nix — sem
# sobreposição de opções entre os três, fusão literal.
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

  # direnv: só HM (home/modules/shell.nix) — tem nix-direnv + integração
  # com zsh de verdade. Um programs.direnv aqui seria redundante.

  # ==================== XDG DESKTOP PORTAL ====================
  # niri não tem DE por trás dele, então precisa de um backend de portal
  # explícito. gnome = screen share/gravação; gtk = file chooser de apps
  # sandboxed/Electron.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
    config.common.default = ["gnome"];
  };

  # ==================== ÁUDIO (PipeWire) ====================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==================== NIX-LD ====================
  # Permite rodar binários dinâmicos genéricos de Linux (ex.: RadioManager
  # de CPS de rádio, instaladores .run) que esperam um ld-linux.so e libs
  # em /lib, coisa que o NixOS não tem fora da Nix store.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib
      libusb1 # acesso USB direto (CPS de rádio, programadores)
      udev
      icu # runtime .NET (RadioManager e outros CPS baseados em .NET)
      fontconfig # SkiaSharp (UI gráfica do RadioManager) precisa pra achar fontes
      freetype
      harfbuzz
    ];
  };

  # ==================== BLUETOOTH ====================
  # Voltado ao estado mínimo original — customizações extras (disable_ertm,
  # Policy.AutoEnable/ReconnectAttempts, regra de udev de autosuspend) já
  # foram testadas e descartadas: nenhuma resolveu, e o mesmo hardware
  # pareia sem problema no Fedora com bluez "de fábrica".
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;
}
