# hosts/macutm/default.nix
#
{ lib, pkgs, pkgs-unstable, common, ... }:

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

  # UTM (Apple Silicon)
  # virtualisation.vmware.guest não se aplica aqui

  # opcional, mas ajuda em VMs
  boot.kernelParams = [ "mitigations=off" ];

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
    # share clipboard with UTM
    spice-vdagent

    zellij yazi jq just duf psmisc asciinema
    lazygit jujutsu lazyjj

    flameshot vlc

     # chromium

    emacs emacsPackages.vterm emacsPackages.pbcopy

    dex lxsession autorandr xkill

    brightnessctl playerctl pciutils pavucontrol ffmpeg

    podman lazydocker gcc gnumake cmake gdb glibc libgcc libcxx

    rust-analyzer rustfmt
    lua-language-server stylua
    gotools golangci-lint-langserver

    python3Packages.python-lsp-server black taplo marksman
  ];

  programs.firefox.enable = lib.mkDefault true;

  # ==================== DOTFILES ====================
  # + input.kdl do Niri apontando para a variante Mac (VM/UTM)
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      "L+ /home/${username}/.config/niri/input.kdl - - - - ${dotfilesDir}/niri/.config/niri/input-mac.kdl"
    ];
}
