# hosts/macbook2011/default.nix
# MacBook Pro 2011-specific configuration (x86_64, real Apple hardware)
{ config, lib, pkgs, common, ... }:
let
  # Inherit common variables from configuration.nix
  inherit (common) username;
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

  # broadcom_sta is flagged insecure upstream (CVE-2019-9501/9502, unmaintained
  # driver). Allowed ONLY for this host's build — scoped here, not globally,
  # so dell1564/macutm/macvmf are unaffected.
  # NOTE: the exact string below is version-pinned; if `nixos-rebuild` later
  # complains about a different broadcom-sta-X.Y.Z string, update this line
  # to match (nixpkgs bumps the driver version over time).
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-7.1.6"
  ];

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

  # ==================== HOME MANAGER (host-specific, fase 3) ====================
  # Override niri input + outputs for physical MacBook 2011 + K380.
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = ../../home/configs/niri/config/input-mac2011.kdl;
    xdg.configFile."niri/config/outputs.kdl".source = ../../home/configs/niri/config/outputs-mac2011.kdl;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-mac2011.jsonc;
  };
}
