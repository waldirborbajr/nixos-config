{ config, pkgs, ... }:

{
  networking.hostName = "ci";

  ############################################
  # Boot (fake, só para avaliação)
  ############################################
  boot.loader.grub.enable = false;
  boot.isContainer = true;

  ############################################
  # Sem interface gráfica
  ############################################
  services.xserver.enable = false;

  ############################################
  # Minimal system
  ############################################
  environment.systemPackages = with pkgs; [
    git
    nix
    bash
    coreutils
  ];

  ############################################
  # Users (mínimo)
  ############################################
  users.users.ci = {
    isNormalUser = true;
    home = "/home/ci";
    shell = pkgs.bash;
  };

  ############################################
  # Desliga coisas desnecessárias
  ############################################
  services.openssh.enable = false;
  networking.firewall.enable = false;

  ############################################
  # State
  ############################################
  system.stateVersion = "25.11";
}
