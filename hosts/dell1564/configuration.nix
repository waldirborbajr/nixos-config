# hosts/dell1564/configuration.nix
# Dell-specific configuration (legacy BIOS machine)
{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../system/profiles/base.nix
    ../../system/profiles/desktop.nix
    ../../system/modules/broadcom-wifi.nix
  ];

  # networking.hostName já vem do specialArg `hostname` em
  # system/profiles/base.nix — não precisa repetir aqui.

  # ==================== KEYBOARD ====================
  # Brazilian ABNT2 layout
  console.keyMap = "br-abnt2";
  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # ==================== GRAPHICS ====================
  hardware.graphics.enable = true;

  # ==================== FILESYSTEM OPTIMIZATIONS ====================
  # Good for older HDDs. NOTE: the actual "noatime nodiratime commit=60"
  # options already live in hardware-configuration.nix (same fileSystems."/"
  # attrset, next to `device`/`fsType`) — do NOT redeclare them here, since
  # NixOS list-type options concatenate across modules instead of
  # overwriting, so a second declaration silently doubled every mount
  # option on the real system.

  # ==================== PACKAGES SPECIFIC TO THIS HOST ====================
  # Keep this list light — Dell is the oldest/slowest machine. Não importa
  # system/profiles/x86/desktop.nix de propósito (é onde vive o resto da
  # lista da família Mac) — brightnessctl/playerctl/pavucontrol vêm do HM
  # (home/modules/desktop.nix), único dono pros 4 hosts NixOS.
  environment.systemPackages = with pkgs; [
    duf
    psmisc
    dex
    autorandr
    xkill

    # Broadcom wireless debug/config tools
    iw
    wirelesstools

    # Basic build tools
    libcxx
    libgcc
  ];

  # ==================== BROWSER (leve, específico deste host) ====================
  # Apenas Firefox estável — máquina antiga/lenta. A família Mac usa
  # Developer Edition (system/modules/mac-family.nix).
  programs.firefox.enable = true;

  system.stateVersion = "26.05";
}
