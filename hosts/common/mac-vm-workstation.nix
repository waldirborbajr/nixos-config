# hosts/common/mac-vm-workstation.nix
#
# Base compartilhada pelas VMs Mac (macutm e macvmf). Só o agente de guest
# da VM (UTM vs VMware Fusion) e o hardware-configuration.nix continuam
# específicos de cada host — o resto é idêntico entre os dois.
{ lib, pkgs, common, ... }:
let
  inherit (common) dotfilesDir dotfileConfigDir username;

  dotfilePrograms = [
    "lazygit"
    "yazi"
  ];

  mkDotfileLink = name:
    "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
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

  # ==================== DOTFILES ====================
  # + input.kdl do Niri apontando para a variante Mac (VM)
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      "L+ /home/${username}/.config/niri/input.kdl - - - - ${dotfilesDir}/niri/.config/niri/input-mac.kdl"
    ];
}
