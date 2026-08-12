# hosts/common/mac-vm-workstation.nix
#
# Base compartilhada pelas VMs Mac (macutm e macvmf). Só o agente de guest
# da VM (UTM vs VMware Fusion) e o hardware-configuration.nix continuam
# específicos de cada host — o resto é idêntico entre os dois.
{ lib, pkgs, common, ... }:
let
  inherit (common) username;
  # Local configs now live inside the flake (fase 3)
  niriInput   = ../../home/configs/niri/input-mac.kdl;
  niriOutputs = ../../home/configs/niri/outputs-macvm.kdl;
in {
  # ==================== BOOT ====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mitigations=off" ]; # ajuda em VMs

  # ==================== CONTAINERS ====================
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # ==================== KEYBOARD ====================
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "mac";

  # ==================== PACKAGES ====================
  environment.systemPackages = with pkgs; [
    zellij yazi jq just duf psmisc asciinema
    lazygit jujutsu lazyjj

    flameshot vlc

    emacs emacsPackages.vterm emacsPackages.pbcopy

    dex autorandr xkill

    brightnessctl playerctl pciutils pavucontrol ffmpeg

    podman lazydocker gcc gnumake cmake gdb glibc libgcc libcxx

    rust-analyzer rustfmt
    lua-language-server stylua
    gotools golangci-lint-langserver

    python3Packages.python-lsp-server black taplo marksman
  ];

  programs.firefox.enable = lib.mkDefault true;

  # ==================== GRAPHICS (VM / virtio-gpu) ====================
  # Required for niri (Wayland) under UTM / Fusion — avoids black screen after login.
  hardware.graphics.enable = true;
  boot.kernelModules = [ "virtio_gpu" "virtio_pci" ];

  # ==================== HOME MANAGER (host-specific, fase 3) ====================
  # Override niri input + outputs for Mac keyboard/trackpad and Virtual-1 display.
  home-manager.users.${username} = {
    xdg.configFile."niri/input.kdl".source   = niriInput;
    xdg.configFile."niri/outputs.kdl".source = niriOutputs;
  };
}
