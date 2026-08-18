# hosts/mac2011/default.nix
# MacBook Pro 2011 — hardware físico Apple (x86_64)
#
# Programas / browsers / teclado / boot EFI → hosts/common/mac-workstation.nix
# Aqui só o que é específico deste hardware (Wi-Fi + niri/waybar físicos).
{ config, lib, pkgs, common, ... }:
let
  inherit (common) username;

  # bluez do nixos-26.05 é 5.86, que tem regressão confirmada de
  # pareamento BR/EDR clássico com o K380 neste controlador Broadcom
  # interno (mac2011): conecta, nunca dispara autenticação, cai sozinho
  # depois de ~18s (ver histórico de debug). Confirmado que a MESMA
  # máquina pareia sem problema no Fedora 42, que usa bluez 5.83.
  # Fixando o source nessa versão exata via overrideAttrs — fica dentro
  # do mesmo nixpkgs-26.05, sem puxar canal/input novo. Só neste host:
  # dell1564/macutm/macvmf não têm K380 e não precisam disso.
  bluezPinned = pkgs.bluez.overrideAttrs (old: rec {
    version = "5.83";
    src = pkgs.fetchurl {
      url = "https://github.com/bluez/bluez/archive/refs/tags/${version}.tar.gz";
      sha256 = "07c878513ef03bb536c06d547506c12771d3823e656993869552b246a02e8a2e";
    };
    # Os patches do nixpkgs (old.patches) foram escritos contra o
    # código-fonte do 5.86 e não se aplicam ao 5.83 — descartamos.
    patches = [];
  });
in {
  imports = [ ../common/mac-workstation.nix ];

  hardware.bluetooth.package = bluezPinned;

  # O módulo hardware.bluetooth do NixOS força General.ControllerMode =
  # "dual" como default (sempre, mesmo sem configurar nada) — em
  # nixos/modules/services/hardware/bluetooth.nix. O controlador
  # Broadcom interno do mac2011 é BR/EDR clássico puro, sem LE de
  # verdade. Forçar "dual" pode travar a máquina de estados de
  # pareamento do bluetoothd esperando uma etapa LE que esse chip nunca
  # cumpre — bate com o sintoma (conecta, fica ~18s parado, cai sozinho
  # depois). Testando "bredr" explícito pra descartar essa hipótese.
  hardware.bluetooth.settings.General.ControllerMode = lib.mkForce "bredr";

  # ==================== WIRELESS (open-source b43) ====================
  # BCM4331 do MacBook Pro 2011 funciona com o driver open-source b43.
  # Evita o broadcom-sta (proprietário, inseguro e quebrando em kernel ≥ 7.1).
  hardware.enableRedistributableFirmware = true;
  networking.enableB43Firmware = true;

  # ---- broadcom-sta (proprietário) — DESATIVADO ----
  # Falha ao compilar contra kernel 7.1.6 (incompatible pointer types no cfg80211).
  # Descomente apenas se precisar voltar ao wl e pinando um kernel mais antigo
  # (ex.: linuxPackages_6_12).
  #
  # nixpkgs.config.permittedInsecurePackages = [
  #   "broadcom-sta-6.30.223.271-59-7.1.6"   # ajuste a string se o Nix reclamar
  # ];
  #
  # boot.blacklistedKernelModules = [
  #   "b43"
  #   "brcmsmac"
  #   "bcma"
  #   "ssb"
  # ];
  #
  # boot.kernelModules = [ "wl" ];
  #
  # boot.extraModulePackages = with config.boot.kernelPackages; [
  #   broadcom_sta
  # ];

  # ==================== GRAPHICS (Mesa/OpenGL) ====================
  # Sem isso, niri e o greeter (cage+regreet, ambos wlroots) não conseguem
  # criar contexto EGL/GBM e ficam mudos — boot completa, gera geração nova,
  # mas nenhuma tela gráfica aparece. Já era feito em mac-vm-workstation.nix
  # (macutm/macvmf) mas nunca tinha sido replicado para o hardware físico.
  hardware.graphics.enable = true;

  # Ferramentas de debug wireless (úteis só com o chip físico) +
  # Spotify: só neste host (não disponível p/ aarch64-linux das VMs UTM/Fusion)
  environment.systemPackages = lib.mkAfter (with pkgs; [
    iw
    wirelesstools
    spotify
    chirp
  ]);

  # ==================== HOME MANAGER (niri/waybar do hardware físico) ====================
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = ../../home/configs/niri/config/input-mac2011.kdl;
    xdg.configFile."niri/config/outputs.kdl".source = ../../home/configs/niri/config/outputs-mac2011.kdl;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-mac2011.jsonc;
  };
}
