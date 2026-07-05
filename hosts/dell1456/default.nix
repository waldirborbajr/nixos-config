# hosts/dell/default.nix
# Dell-specific configuration (legacy BIOS machine)
{ lib, pkgs, pkgs-unstable, common, ... }:

let
  # Inherit common variables from configuration.nix
  inherit (common) dotfilesDir dotfileConfigDir;

  # Dotfiles specific to this host (Dell)
  # Keep this list minimal — only add what this machine actually needs
  dotfilePrograms = [
    # Example: add host-specific dotfiles here if needed
    "lazygit"
  ];

  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # ==================== BOOTLOADER ====================
  # Override to use legacy BIOS + GRUB (Dell old hardware)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";        # ← Confirm with `lsblk -f` on the Dell
    # useOSProber = true;       # Uncomment if you have Windows dual boot
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

  # ==================== PACKAGES SPECIFIC TO DELL ====================
  # Keep this list light — Dell is the oldest/slowest machine
  environment.systemPackages = with pkgs; [
    # Core utilities
    yazi
    jq
    just
    duf
    psmisc
    asciinema
    stow

    # Development & tools
    lazygit
    jujutsu
    lazyjj

    # Desktop utilities
    dex
    lxsession
    autorandr
    xkill
    brightnessctl
    playerctl
    pciutils
    pavucontrol

    # Basic build tools
    gdb
    glibc
    libcxx
    libgcc
  ]
  ++ (with pkgs-unstable; [
    # Unstable packages specific to this host
    neovim
  ]);

  # ==================== HOST-SPECIFIC DOTFILES ====================
  # Only symlink dotfiles that are specific to this Dell machine
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
