# modules/hardware/macbook.nix
{ config, pkgs, ... }:

{
  # Habilita firmware redistribuível (inclui alguns Broadcom genéricos)
  hardware.enableRedistributableFirmware = true;

  # Blacklist módulos open-source que conflitam com o driver proprietário
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  # Carrega o módulo proprietário Broadcom (wl)
  boot.kernelModules = [ "wl" ];

  # Adiciona o pacote do driver como extra module
  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  # Opcional: se você quiser tentar b43 em vez de broadcom_sta, comente acima e use isso:
  # boot.kernelModules = [ "b43" ];
  # boot.blacklistedKernelModules = [ "wl" "brcmsmac" ];
  # hardware.firmware = with pkgs; [
  #   b43Firmware_6_30_163_46   # versão mais recente comum
  #   # ou b43Firmware_5_1_138 se seu chip for muito antigo
  # ];

  # Pacotes úteis para debug/wireless (não obrigatórios, mas ajudam)
  environment.systemPackages = with pkgs; [
    iw
    wirelesstools  # inclui iwconfig, etc.
    rfkill
  ];
}
