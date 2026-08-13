# hosts/mac2011/default.nix
# MacBook Pro 2011 — hardware físico Apple (x86_64)
#
# Programas / browsers / teclado / boot EFI → hosts/common/mac-workstation.nix
# Aqui só o que é específico deste hardware (Broadcom wl + niri/waybar físicos).
{ config, lib, pkgs, common, ... }:
let
  inherit (common) username;
in {
  imports = [ ../common/mac-workstation.nix ];

  # ==================== BROADCOM WIRELESS ====================
  # Este MacBook usa chip Broadcom que precisa do driver proprietário wl.
  hardware.enableRedistributableFirmware = true;

  # broadcom_sta é marcado insecure upstream (CVE-2019-9501/9502, driver
  # sem manutenção). Permitido SOMENTE neste host — não afeta dell/macutm/macvmf.
  # Se o nixos-rebuild reclamar de outra string broadcom-sta-X.Y.Z, atualize
  # a linha abaixo para bater com a versão do nixpkgs pinado.
  nixpkgs.config.permittedInsecurePackages = [
    "broadcom-sta-6.30.223.271-59-7.1.6"
  ];

  # Blacklist dos drivers open-source que conflitam com o wl proprietário
  boot.blacklistedKernelModules = [
    "b43"
    "brcmsmac"
    "bcma"
    "ssb"
  ];

  boot.kernelModules = [ "wl" ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    broadcom_sta
  ];

  # Ferramentas de debug wireless (úteis só com o chip físico)
  environment.systemPackages = lib.mkAfter (with pkgs; [
    iw
    wirelesstools
  ]);

  # ==================== HOME MANAGER (niri/waybar do hardware físico) ====================
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = ../../home/configs/niri/config/input-mac2011.kdl;
    xdg.configFile."niri/config/outputs.kdl".source = ../../home/configs/niri/config/outputs-mac2011.kdl;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-mac2011.jsonc;
  };
}
