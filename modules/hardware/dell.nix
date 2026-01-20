{ ... }:

{
  ############################################
  # Dell-specific hardware configuration
  ############################################

  # Allow redistributable firmware (required for Broadcom, Intel, etc.)
  hardware.enableRedistributableFirmware = true;

  ############################################
  # Broadcom wireless (B43)
  #
  # Firmware is handled declaratively by NixOS.
  # DO NOT install b43 firmware via systemPackages.
  ############################################
  networking.enableB43Firmware = true;

  # Prevent conflicting Broadcom drivers
  boot.blacklistedKernelModules = [
    "brcmsmac"
    "wl"
  ];

  ############################################
  # (Optional) Future Dell-specific tweaks
  #
  # Examples:
  # - thermal control
  # - power management
  # - touchpad quirks
  #
  # Keep this file hardware-only.
  ############################################
}
