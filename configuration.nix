{ config, pkgs, lib, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ./hardware-configuration-dell.nix
    ./modules/hardware-dell.nix
    ./modules/kernel-tuning.nix
    ./modules/desktop-gnome.nix
    ./modules/fonts.nix
    ./modules/system-programs.nix
    ./modules/system-packages.nix
    ./modules/containers/docker.nix
    ./modules/containers/k3s.nix
    ./modules/maintenance.nix
    ./modules/maintenance-hm.nix
    ./modules/user-borba.nix
    ./modules/nix-unstable.nix
  ];

  ############################################
  # Host
  ############################################
  networking.hostName = "nixos";

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
  # Nix configuration
  ############################################
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  ############################################
  # Remote access (SSH)
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312 fixes)
  ############################################
  networking.networkmanager.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Força carregamento dos módulos corretos
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  # Pacotes de firmware e utilitários
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    b43-fwcutter
    wireless_tools
    pciutils
    usbutils
  ];

  ############################################
  # Bootloader (GRUB) - Dell BIOS / Legacy
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = false;      # evita warnings de outros OS
  boot.loader.grub.devices = [ "/dev/sda" ]; # apenas o disco físico de boot

  ############################################
  # GNOME Desktop (Wayland)
  ############################################
  services.xserver.enable = true;
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  services.desktopManager.gnome.enable = true;

  services.gnome = {
    core-apps.enable = false;
    gnome-keyring.enable = true;
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };

  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
