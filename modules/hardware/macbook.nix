# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
  ############################################
  # Firmware & drivers
  ############################################

  # Habilita firmware redistribuível Broadcom / Intel / Realtek
  hardware.enableRedistributableFirmware = true;

  # Blacklist drivers open-source que podem conflitar com o Broadcom proprietário
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Carrega o driver proprietário Broadcom (wl)
  boot.kernelModules = [ "wl" ];

  # Pacotes úteis para debug / wireless
  environment.systemPackages = with pkgs; [
    iw            # Ferramenta wireless avançada
    wirelesstools # Inclui iwconfig, ifconfig, etc.
  ];
}
