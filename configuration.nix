{ config, pkgs, lib, ... }:

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
    # ./modules/containers/podman.nix   # Desativado enquanto Docker estiver ativo
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
  # GNOME + Wayland
  ############################################
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.displayManager.gdm.wayland = true;
  services.displayManager.gdm.autoSuspend = false;
  services.displayManager.autoLogin = {
    enable = true;
    user = "borba";
  };
  services.desktopManager.gnome.enable = true;

  # Força GNOME core-apps para evitar conflito de módulos
  services.gnome.core-apps.enable = lib.mkForce true;
  services.gnome.gnome-keyring.enable = true;

  # Sessão Wayland
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    TERMINAL = "alacritty";
  };

  # XDG portals
  xdg.portal.enable = true;
  xdg.portal.extraPortals = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];

  ############################################
  # Wi-Fi e Bluetooth (Broadcom BCM4312)
  ############################################
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Firmware Broadcom
  environment.systemPackages = with pkgs; [
    linux-firmware
    bluez
    blueman
    b43-fwcutter
    wirelesstools
    pciutils
    usbutils
    rfkill
  ];

  # Carregamento dos módulos corretos
  boot.initrd.kernelModules = [ "ssb" "b43" "btusb" ];
  boot.kernelModules = [ "ssb" "b43" ];
  boot.blacklistedKernelModules = [ "bcma" "brcmsmac" "wl" ];

  ############################################
  # Docker (prioridade)
  ############################################
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  # Podman comentado para uso futuro
  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerCompat = true;

  ############################################
  # Bootloader (GRUB)
  ############################################
  boot.loader.grub.enable = true;
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.devices = [ "/dev/sda" ]; # Dell Inspiron BIOS legacy

  ############################################
  # System state version
  ############################################
  system.stateVersion = "25.11";
}
