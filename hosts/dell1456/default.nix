# hosts/dell/default.nix
{
  lib,
  pkgs,
  pkgs-unstable,
  ...
}: let
  dotfilesDir = "/home/borba/dotfiles";
  dotfileConfigDir = "/home/borba/.config";

  # Dotfiles específicos deste host (UTM)
  dotfilePrograms = [
    "lazygit"
    "yazi"
    # adicione aqui outros dotfiles específicos do UTM no futuro
  ];

  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # Sobrescreve bootloader para BIOS legacy (Dell antigo)
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # ← CONFIRME com `lsblk -f` no Dell
    # useOSProber = true;       # descomente se tiver Windows dual boot
  };

  # Teclado ABNT2 (pt-BR)
  console.keyMap = "br-abnt2";

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };

  # Opcional: otimizações de performance para HDD (se for o caso)
  fileSystems."/" = {
    options = ["noatime" "nodiratime" "commit=60"];
  };

  # ==================== PACOTES PARA ESTA MÁQUINA ====================
  environment.systemPackages = with pkgs;
    [
      # Pacotes extras (não presentes no configuration.nix base)
      yazi
      jq
      just
      duf
      psmisc
      asciinema
      stow
      lazygit
      jujutsu
      lazyjj
      dex
      lxsession
      autorandr
      xkill
      brightnessctl
      playerctl
      pciutils
      pavucontrol
      gdb
      glibc
      libcxx
      libgcc
    ]
    ++ (with pkgs-unstable; [
      # Pacotes unstable específicos desta máquina
      neovim
    ]);

  # ==================== DOTFILES ESPECÍFICOS DESTE HOST ====================
  systemd.tmpfiles.rules = map mkDotfileLink dotfilePrograms;
}
