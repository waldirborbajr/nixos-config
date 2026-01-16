# # { config, pkgs, ... }:

# # {
# #   ############################################
# #   # Nix
# #   ############################################
# #   nix.settings.experimental-features = [ "nix-command" "flakes" ];

# #   nix.gc = {
# #     automatic = true;
# #     dates = "daily";
# #     options = "--delete-older-than 2d";
# #   };

# #   nixpkgs.config.allowUnfree = true;

# #   ############################################
# #   # Locale / Time
# #   ############################################
# #   time.timeZone = "America/Sao_Paulo";

# #   i18n.defaultLocale = "en_US.UTF-8";
# #   i18n.extraLocaleSettings = {
# #     LC_ADDRESS = "pt_BR.UTF-8";
# #     LC_IDENTIFICATION = "pt_BR.UTF-8";
# #     LC_MEASUREMENT = "pt_BR.UTF-8";
# #     LC_MONETARY = "pt_BR.UTF-8";
# #     LC_NAME = "pt_BR.UTF-8";
# #     LC_NUMERIC = "pt_BR.UTF-8";
# #     LC_PAPER = "pt_BR.UTF-8";
# #     LC_TELEPHONE = "pt_BR.UTF-8";
# #     LC_TIME = "pt_BR.UTF-8";
# #   };

# #   ############################################
# #   # Networking
# #   ############################################
# #   networking.networkmanager.enable = true;

# #   ############################################
# #   # GNOME + Wayland
# #   ############################################
# #   services.xserver.enable = true;

# #   services.xserver.displayManager.gdm = {
# #     enable = true;
# #     wayland = true;

# #     autoLogin = {
# #       enable = true;
# #       user = "borba";
# #     };
# #   };

# #   services.xserver.desktopManager.gnome.enable = true;

# #   ############################################
# #   # Audio (PipeWire)
# #   ############################################
# #   services.pulseaudio.enable = false;
# #   security.rtkit.enable = true;

# #   services.pipewire = {
# #     enable = true;
# #     alsa.enable = true;
# #     alsa.support32Bit = true;
# #     pulse.enable = true;
# #   };

# #   ############################################
# #   # Wayland Env
# #   ############################################
# #   environment.sessionVariables = {
# #     XDG_SESSION_TYPE = "wayland";
# #     QT_QPA_PLATFORM = "wayland";
# #     MOZ_ENABLE_WAYLAND = "1";
# #     NIXOS_OZONE_WL = "1";
# #     TERMINAL = "alacritty";
# #   };

# #   ############################################
# #   # XDG Portal
# #   ############################################
# #   xdg.portal = {
# #     enable = true;
# #     extraPortals = with pkgs; [
# #       xdg-desktop-portal-gnome
# #       xdg-desktop-portal-gtk
# #     ];
# #   };

# #   ############################################
# #   # Services
# #   ############################################
# #   services.openssh.enable = true;
# #   networking.firewall.allowedTCPPorts = [ 22 ];

# #   ############################################
# #   # Docker
# #   ############################################
# #   virtualisation.docker = {
# #     enable = true;
# #     enableOnBoot = true;
# #   };

# #   ############################################
# #   # Users / Sudo
# #   ############################################
# #   users.users.borba = {
# #     isNormalUser = true;
# #     extraGroups = [
# #       "wheel"
# #       "networkmanager"
# #       "docker"
# #     ];
# #   };

# #   security.sudo = {
# #     enable = true;
# #     wheelNeedsPassword = false;
# #   };

# #   ############################################
# #   # Default Terminal (Global)
# #   ############################################
# #   xdg.mime.defaultApplications = {
# #     "application/x-terminal-emulator" = "alacritty.desktop";
# #   };

# #   ############################################
# #   # System
# #   ############################################
# #   system.stateVersion = "25.11";
# # }

# { config, pkgs, ... }:

# {
#   ############################################
#   # Nix — Performance, Store e Flakes
#   ############################################
#   nix.settings = {
#     experimental-features = [ "nix-command" "flakes" ];

#     # Otimiza o /nix/store (remove duplicações)
#     auto-optimise-store = true;

#     # Melhor uso de CPU em builds
#     max-jobs = "auto";
#     cores = 0;

#     # Evita warning em repos dirty
#     warn-dirty = false;
#   };

#   # Garbage Collection automático
#   nix.gc = {
#     automatic = true;
#     dates = "daily";

#     # Ajuste conforme perfil:
#     # Desktop: 2d | Dev intenso: 1d
#     options = "--delete-older-than 2d";
#   };

#   # Mantém poucas gerações no bootloader
#   boot.loader.systemd-boot.configurationLimit = 5;

#   nixpkgs.config.allowUnfree = true;

#   ############################################
#   # Locale / Time
#   ############################################
#   time.timeZone = "America/Sao_Paulo";

#   i18n.defaultLocale = "en_US.UTF-8";
#   i18n.extraLocaleSettings = {
#     LC_ADDRESS = "pt_BR.UTF-8";
#     LC_IDENTIFICATION = "pt_BR.UTF-8";
#     LC_MEASUREMENT = "pt_BR.UTF-8";
#     LC_MONETARY = "pt_BR.UTF-8";
#     LC_NAME = "pt_BR.UTF-8";
#     LC_NUMERIC = "pt_BR.UTF-8";
#     LC_PAPER = "pt_BR.UTF-8";
#     LC_TELEPHONE = "pt_BR.UTF-8";
#     LC_TIME = "pt_BR.UTF-8";
#   };

#   ############################################
#   # Networking
#   ############################################
#   networking.networkmanager.enable = true;

#   ############################################
#   # GNOME + Wayland
#   ############################################
#   services.xserver.enable = true;

#   services.xserver.displayManager.gdm = {
#     enable = true;
#     wayland = true;

#     autoLogin = {
#       enable = true;
#       user = "borba";
#     };
#   };

#   services.xserver.desktopManager.gnome.enable = true;

#   ############################################
#   # Audio — PipeWire (Low Latency)
#   ############################################
#   services.pulseaudio.enable = false;
#   security.rtkit.enable = true;

#   services.pipewire = {
#     enable = true;

#     alsa.enable = true;
#     alsa.support32Bit = true;
#     pulse.enable = true;

#     # Ajuste fino para menor latência
#     extraConfig.pipewire."92-low-latency" = {
#       context.properties = {
#         default.clock.rate = 48000;
#         default.clock.quantum = 256;
#         default.clock.min-quantum = 128;
#         default.clock.max-quantum = 1024;
#       };
#     };
#   };

#   ############################################
#   # Wayland — Variáveis de Sessão
#   ############################################
#   environment.sessionVariables = {
#     # Wayland base
#     XDG_SESSION_TYPE = "wayland";
#     QT_QPA_PLATFORM = "wayland";
#     MOZ_ENABLE_WAYLAND = "1";
#     NIXOS_OZONE_WL = "1";

#     # Melhor compatibilidade gráfica
#     SDL_VIDEODRIVER = "wayland";
#     CLUTTER_BACKEND = "wayland";

#     # Terminal padrão
#     TERMINAL = "alacritty";
#   };

#   ############################################
#   # XDG Desktop Portals
#   ############################################
#   xdg.portal = {
#     enable = true;

#     extraPortals = with pkgs; [
#       xdg-desktop-portal-gnome
#       xdg-desktop-portal-gtk
#     ];
#   };

#   ############################################
#   # systemd — Boot mais rápido
#   ############################################
#   systemd.extraConfig = ''
#     DefaultTimeoutStartSec=15s
#     DefaultTimeoutStopSec=10s
#   '';

#   ############################################
#   # SSH
#   ############################################
#   services.openssh = {
#     enable = true;

#     settings = {
#       UseDNS = false;
#       PasswordAuthentication = false;
#     };
#   };

#   networking.firewall.allowedTCPPorts = [ 22 ];

#   ############################################
#   # Docker — Disk & Performance
#   ############################################
#   virtualisation.docker = {
#     enable = true;
#     enableOnBoot = true;

#     # Limpa imagens, containers e volumes antigos
#     autoPrune = {
#       enable = true;
#       dates = "daily";
#       flags = [
#         "--all"
#         "--volumes"
#       ];
#     };
#   };

#   ############################################
#   # Users / Sudo
#   ############################################
#   users.users.borba = {
#     isNormalUser = true;

#     extraGroups = [
#       "wheel"
#       "networkmanager"
#       "docker"
#     ];
#   };

#   security.sudo = {
#     enable = true;
#     wheelNeedsPassword = false;
#   };

#   ############################################
#   # Default Terminal (Global)
#   ############################################
#   xdg.mime.defaultApplications = {
#     "application/x-terminal-emulator" = "alacritty.desktop";
#   };

#   ############################################
#   # System
#   ############################################
#   system.stateVersion = "25.11";
# }

{ config, pkgs, ... }:

{

  ############################################
  # Firmware
  ############################################
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Nix — Performance, Store e Flakes
  ############################################
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    warn-dirty = false;
  };

  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 2d";
  };

  # Limita gerações no bootloader (GRUB)
  boot.loader.grub.configurationLimit = 5;

  nixpkgs.config.allowUnfree = true;

  ############################################
  # Locale / Time
  ############################################
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  ############################################
  # Networking
  ############################################
  networking.networkmanager.enable = true;

  ############################################
  # GNOME + Wayland
  ############################################
  services.xserver.enable = true;

  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoLogin = {
      enable = true;
      user = "borba";
    };
  };

  services.xserver.desktopManager.gnome.enable = true;

  ############################################
  # Audio — PipeWire (Low Latency)
  ############################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 256;
        default.clock.min-quantum = 128;
        default.clock.max-quantum = 1024;
      };
    };
  };

  ############################################
  # Wayland — Variáveis de Sessão
  ############################################
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland;xcb";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    TERMINAL = "alacritty";
  };

  ############################################
  # XDG Desktop Portals
  ############################################
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  ############################################
  # systemd — Boot mais rápido
  ############################################
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "15s";
    DefaultTimeoutStopSec = "10s";
  };

  ############################################
  # SSH
  ############################################
  services.openssh = {
    enable = true;
    settings = {
      UseDNS = false;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Docker — Disk & Performance
  ############################################
  #  virtualisation.docker = {
  #    enable = true;
  #    enableOnBoot = true;
  #    autoPrune = {
  #      enable = true;
  #      dates = "daily";
  #      flags = [ "--all" "--volumes" ];
  #    };
  #  };

  ############################################
  # Containers — Docker + Podman
  ############################################
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
      autoPrune = {
        enable = true;
        dates = "daily";
        flags = [
          "--all"
          "--volumes"
        ];
      };
    };

    # podman = {
    #   enable = true;
    #
    #   # Permite usar docker CLI apontando para o podman
    #   dockerCompat = true;
    #
    #   # Cria /run/docker.sock via podman (DevPod, compose, etc.)
    #   dockerSocket.enable = true;
    #
    #   defaultNetwork.settings.dns_enabled = true;
    # };
  };

  # Necessário para rootless containers (Podman)
  security.unprivilegedUsernsClone = true;

  ############################################
  # Users / Sudo
  ############################################
  users.users.borba = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  ############################################
  # Default Terminal
  ############################################
  xdg.mime.defaultApplications = {
    "application/x-terminal-emulator" = "alacritty.desktop";
  };

  ############################################
  # System
  ############################################
  system.stateVersion = "25.11";
}
