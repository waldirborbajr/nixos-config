# hosts/dell/default.nix
# Dell-specific configuration (legacy BIOS machine)
{ lib, pkgs, pkgs-unstable, common, ... }:
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
