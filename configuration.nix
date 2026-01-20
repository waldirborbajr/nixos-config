{ config, pkgs, ... }:

{
  ############################################
  # Imports
  ############################################
  imports = [
    ./hardware-configuration-dell.nix
    ./modules/hardware-dell.nix
    ./modules/hardware-radio-chirp.nix
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
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  ############################################
  # Remote access (SSH)
  ############################################
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312)
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Firmware Broadcom BCM4312 LP-PHY
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    b43-fwcutter
    wireless-tools
    pciutils
    usbutils
  ];

  # Módulos para initrd e kernel
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];

  # Evita conflitos com outros drivers Broadcom
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  ############################################
  # GRUB (Legacy BIOS Dell)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.devices = [ "/dev/sda" ];

  ############################################
  # Desktop (GNOME / Wayland)
  ############################################
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.gdm.autoSuspend = false;

  services.desktopManager.gnome.enable = true;

  services.gnome.core-apps.enable = true;
  services.gnome.gnome-keyring.enable = true;

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];

  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };

  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services.journald.extraConfig = ''
    SystemMaxUse=200M
    RuntimeMaxUse=50M
  '';

  systemd.services.NetworkManager-wait-online.enable = false;

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
