# hosts/dell/default.nix
# Dell-specific configuration (legacy BIOS machine)
{ config, lib, pkgs, pkgs-unstable, common, ... }:
let
  # Inherit common variables from configuration.nix
  inherit (common) dotfilesDir dotfileConfigDir;
  # Dotfiles specific to this host (Dell)
  # Keep this list minimal — only add what this machine actually needs
  dotfilePrograms = [
    "lazygit"
    # Example: add more host-specific dotfiles here if needed
  ];
  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # ==================== BOOTLOADER ====================
  # Assumes legacy BIOS + GRUB (older Dell hardware).
  # TODO: confirm with `ls /sys/firmware/efi` — if that path exists, this
  # machine actually boots via UEFI and should use systemd-boot instead,
  # like m2utm/macbook2011.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # confirm with `lsblk -f` on the Dell
    # useOSProber = true; # uncomment if dual-booting Windows
  };

  # ==================== KEYBOARD ====================
  # Brazilian ABNT2 layout
  console.keyMap = "br-abnt2";
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # ==================== FILESYSTEM OPTIMIZATIONS ====================
  # Good for older HDDs
  fileSystems."/" = {
    options = [ "noatime" "nodiratime" "commit=60" ];
  };

  # ==================== BROADCOM WIRELESS ====================
  # This Dell has a Broadcom BCM4312 802.11b/g (PCI ID 14e4:4315) that needs
  # the proprietary wl driver — the open b43 driver is unreliable on this
  # LP-PHY revision. Set only here (per-host), not in configuration.nix, so
  # it does NOT apply to mac2011/macutm/macvmf.
  hardware.enableRedistributableFirmware = true;

  # broadcom_sta is flagged insecure upstream (CVE-2019-9501/9502, unmaintained
  # driver). Allowed ONLY for this host's build — scoped here, not globally,
  # so mac2011/macutm/macvmf still refuse to build it if ever referenced.
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
  # Keep this list light — Dell is the oldest/slowest machine
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
  # Only symlink dotfiles specific to this Dell machine
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
