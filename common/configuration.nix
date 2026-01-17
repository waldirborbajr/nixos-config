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
    autoLogin.enable = true;
    autoLogin.user = "borba";
  };

  services.xserver.desktopManager.gnome.enable = true;

  ############################################
  # Audio — PipeWire
  ############################################
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  ############################################
  # Wayland — Session Variables
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
  # systemd — Faster Boot
  ############################################
  systemd.settings.Manager = {
    DefaultTimeoutStartSec = "15s";
    DefaultTimeoutStopSec = "10s";
  };

  ############################################
  # SSH — SEM duplicação
  ############################################
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Containers — Docker
  ############################################
  virtualisation.docker = {
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

  programs.zsh.enable = true;

  ############################################
  # System
  ############################################
  system.stateVersion = "25.11";
}
