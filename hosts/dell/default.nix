# # { ... }:

# # {
# #   imports = [
# #     ./hardware-configuration.nix
# #   ];

# #   networking.hostName = "dell";

# #   ############################################
# #   # Bootloader
# #   ############################################
# #   boot.loader.grub = {
# #     enable = true;
# #     device = "/dev/sda";
# #     useOSProber = true;
# #   };

# #   ############################################
# #   # Keyboard (Dell = PT-BR)
# #   ############################################
# #   services.xserver.xkb = {
# #     layout = "br";
# #     variant = "";
# #   };

# #   console.keyMap = "br-abnt2";
# # }

# { ... }:

# {
#   imports = [
#     ./hardware-configuration.nix
#   ];

#   ############################################
#   # Host
#   ############################################
#   networking.hostName = "dell";

#   ############################################
#   # Bootloader
#   ############################################
#   boot.loader.grub = {
#     enable = true;
#     device = "/dev/sda";
#     useOSProber = false;
#     timeout = 2;
#   };

#   # Dell Inspiron – Intel Wi-Fi
#   boot.kernelModules = [ "iwlwifi" ];

#   boot.extraModprobeConfig = ''
#     options iwlwifi power_save=0
#   '';


#   ############################################
#   # CPU / Power
#   ############################################
#   powerManagement.cpuFreqGovernor = "schedutil";

#   ############################################
#   # Firmware / Microcode
#   ############################################
#   hardware.enableRedistributableFirmware = true;
#   hardware.cpu.intel.updateMicrocode = true;

#   ############################################
#   # Keyboard (Dell = PT-BR)
#   ############################################
#   services.xserver.xkb = {
#     layout = "br";
#     variant = "";
#   };

#   console.keyMap = "br-abnt2";

#   ############################################
#   # Input (Wayland friendly)
#   ############################################
#   services.libinput.enable = true;

#   ############################################
#   # RTC
#   ############################################
#   time.hardwareClockInLocalTime = false;

#   ############################################
#   # I/O Scheduler (SSD / NVMe)
#   ############################################
#   services.udev.extraRules = ''
#     ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
#     ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
#   '';

#   ############################################
#   # Dell Inspiron – Wi-Fi Intel
#   ############################################
#   boot.kernelModules = [ "iwlwifi" ];

#   boot.extraModprobeConfig = ''
#     options iwlwifi power_save=0
#   '';

# }

{ ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "dell";

  ############################################
  # Bootloader
  ############################################
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
    useOSProber = false;
    timeout = 2;
  };

  ############################################
  # Intel Wi-Fi (Dell Inspiron)
  ############################################
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0
  '';

  ############################################
  # CPU / Power
  ############################################
  powerManagement.cpuFreqGovernor = "schedutil";

  ############################################
  # Input
  ############################################
  services.libinput.enable = true;

  ############################################
  # Keyboard
  ############################################
  services.xserver.xkb.layout = "br";
  console.keyMap = "br-abnt2";

  ############################################
  # RTC
  ############################################
  time.hardwareClockInLocalTime = false;

  ############################################
  # I/O Scheduler (SSD / NVMe)
  ############################################
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="nvme*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"
  '';  
}
