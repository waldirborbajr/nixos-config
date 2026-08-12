# hosts/dell/default.nix
# Dell-specific configuration (legacy BIOS machine)
{ lib, pkgs, common, ... }:
let
  # Inherit common variables from configuration.nix
  inherit (common) username;
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
  # Good for older HDDs. NOTE: the actual "noatime nodiratime commit=60"
  # options already live in hardware-configuration.nix (same fileSystems."/"
  # attrset, next to `device`/`fsType`) — do NOT redeclare them here, since
  # NixOS list-type options concatenate across modules instead of
  # overwriting, so a second declaration silently doubled every mount
  # option on the real system.

  # ==================== BROADCOM WIRELESS ====================
  # This Dell has a Broadcom BCM4312 802.11b/g LP-PHY (PCI ID 14e4:4315).
  #
  # ATTEMPT 1 (reverted): proprietary `wl` driver (broadcom_sta). Failed to
  # build against boot.kernelPackages = linuxPackages_latest (7.1.6) — the
  # driver is unmaintained since ~2016 and its cfg80211 callbacks
  # (add_key/del_key/get_key) use the old net_device-based signature, which
  # no longer matches current kernel headers (wireless_dev-based now). This
  # is a hard incompatibility, not a version-string/insecure-package issue —
  # no amount of permittedInsecurePackages fixes a compile error.
  #
  # ATTEMPT 2 (current): open-source in-tree `b43` driver + extracted
  # firmware. b43 ships with the kernel itself (no out-of-tree module to
  # compile against a moving kernel ABI), so it doesn't rot the same way.
  # Set only here (per-host), not in configuration.nix, so it does NOT apply
  # to mac2011/macutm/macvmf.
  hardware.enableRedistributableFirmware = true;

  # b43 needs firmware version 6.30.163.46 specifically for LP-PHY chips
  # (this Dell's revision) — newer/older firmware versions target different
  # PHY generations and won't work with this card.
  hardware.firmware = [ pkgs.b43Firmware_6_30_163_46 ];

  # No blacklist needed: b43/bcma/ssb are the drivers we WANT this time.
  # (Contrast with the old `wl`-based approach, which had to blacklist these
  # to avoid the two drivers fighting over the same device.)

  # b43 is a regular kernel module (boot.kernelModules), no extraModulePackages
  # needed since it ships in-tree — the kernel build already includes it.
  boot.kernelModules = [ "b43" ];

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
    # lxsession   ← remover (puxa lxpolkit e conflita com soteria)
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
  # Override niri input + outputs for Dell ABNT2 keyboard and internal panel.
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = ../../home/configs/niri/config/input-dell.kdl;
    xdg.configFile."niri/config/outputs.kdl".source = ../../home/configs/niri/config/outputs-dell.kdl;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-dell.jsonc;
  };
}
