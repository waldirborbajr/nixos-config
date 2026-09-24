# hosts/dell1564/boot.nix
{
  lib,
  pkgs,
  ...
}: {
  # ==================== BOOTLOADER ====================
  # Assumes legacy BIOS + GRUB (older Dell hardware).
  # TODO: confirm with `ls /sys/firmware/efi` — if that path exists, this
  # machine actually boots via UEFI and should use systemd-boot instead,
  # like the mac family.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # confirm with `lsblk -f` on the Dell
    # useOSProber = true; # uncomment if dual-booting Windows
  };

  # ==================== BROADCOM WIRELESS (kernel module + firmware) ====================
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
  # hardware.enableRedistributableFirmware = true; comes from
  # system/modules/broadcom-wifi.nix — shared only with mac2011, the other
  # physical Broadcom host; does NOT apply to macutm/macvmf (VMs, no
  # physical Wi-Fi).

  # b43 needs firmware version 6.30.163.46 specifically for LP-PHY chips
  # (this Dell's revision) — newer/older firmware versions target different
  # PHY generations and won't work with this card.
  hardware.firmware = [pkgs.b43Firmware_6_30_163_46];

  # No blacklist needed: b43/bcma/ssb are the drivers we WANT this time.
  # (Contrast with the old `wl`-based approach, which had to blacklist these
  # to avoid the two drivers fighting over the same device.)

  # b43 is a regular kernel module, no extraModulePackages needed since it
  # ships in-tree — the kernel build already includes it.
  boot.kernelModules = ["b43"];
}
