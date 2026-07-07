# hosts/macbook2011/default.nix
# MacBook Pro 2011-specific configuration (x86_64, real Apple hardware)
{ lib, pkgs, pkgs-unstable, common, ... }:
let
  # Inherit common variables from configuration.nix
  inherit (common) dotfilesDir dotfileConfigDir;
  # Dotfiles specific to this host
  # Keep this list minimal — only add what this machine actually needs
  dotfilePrograms = [
    "lazygit"
    # Add more host-specific dotfiles here if needed
  ];
  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # ==================== BOOTLOADER ====================
  # Confirmed EFI via hardware-configuration.nix (/boot is vfat with
  # fmask/dmask, i.e. an EFI System Partition) — same as m2utm.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==================== KEYBOARD ====================
  # US layout, matching m2utm.
  # NOTE: this is real Apple hardware with a physical Mac keyboard layout.
  # variant "mac" remaps keys (media keys, modifier placement) to match the
  # built-in keyboard — same reasoning as m2utm. Remove if it causes issues
  # with an external non-Apple keyboard.
  console.keyMap = "us";
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # ==================== BROADCOM WIRELESS ====================
  # This MacBook uses a Broadcom chip that needs the proprietary wl driver.
  # Recovered from a backup of the machine's previous config.
  hardware.enableRedistributableFirmware = true;

  # Blacklist open-source drivers that conflict with the proprietary Broadcom driver
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Proprietary Broadcom driver
  boot.kernelModules = [ "wl" ];

  # Driver package built against the active kernel
  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  # ==================== PACKAGES SPECIFIC TO THIS HOST ====================
  # Keep this list light — old spinning-rust-era hardware, similar tier to Dell
  environment.systemPackages = with pkgs; [
    # Terminal & shell utilities
    yazi
    jq
    just
    duf
    psmisc
    asciinema

    # Version control
    lazygit
    jujutsu
    lazyjj

    # Desktop utilities
    dex
    lxsession
    autorandr
    xkill

    # Hardware & multimedia
    brightnessctl
    playerctl
    pciutils
    pavucontrol

    # Broadcom wireless debug/config tools
    iw
    wirelesstools

    # Basic build tools
    gdb
    glibc
    libcxx
    libgcc
  ];
  # NOTE: pkgs-unstable.neovim already comes from configuration.nix.
  # Not repeated here to avoid duplicate entries in systemPackages.

  # ==================== HOST-SPECIFIC DOTFILES ====================
  # Only symlink dotfiles specific to this MacBook 2011 machine
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
