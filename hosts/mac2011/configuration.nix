# hosts/mac2011/configuration.nix
# MacBook Pro 2011 — hardware físico Apple (x86_64)
#
# Programas / browsers / teclado / boot EFI → system/modules/mac-family.nix
# Extras opcionais (media, DAW, brave...) → system/profiles/x86/desktop.nix
# Aqui só o que é específico deste hardware (Wi-Fi físico + quirks).
{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../system/profiles/base.nix
    ../../system/profiles/desktop.nix
    ../../system/profiles/x86/desktop.nix
    ../../system/modules/mac-family.nix
    ../../system/modules/broadcom-wifi.nix
  ];

  # O módulo hardware.bluetooth do NixOS força General.ControllerMode =
  # "dual" como default (sempre, mesmo sem configurar nada). O
  # controlador Broadcom interno do mac2011 é BR/EDR clássico puro, sem
  # LE de verdade. Testando "bredr" explícito.
  hardware.bluetooth.settings.General.ControllerMode = lib.mkForce "bredr";

  # ==================== WIRELESS (open-source b43) ====================
  # BCM4331 do MacBook Pro 2011 funciona com o driver open-source b43.
  # Evita o broadcom-sta (proprietário, inseguro e quebrando em kernel ≥ 7.1).
  # hardware.enableRedistributableFirmware = true; vem de
  # system/modules/broadcom-wifi.nix (imported above) — compartilhado só
  # com dell1564, o outro host Broadcom físico.
  networking.enableB43Firmware = true;

  # ---- broadcom-sta (proprietário) — DESATIVADO ----
  # Falha ao compilar contra kernel 7.1.6 (incompatible pointer types no
  # cfg80211). Descomente apenas se precisar voltar ao wl e pinando um
  # kernel mais antigo (ex.: linuxPackages_6_12).
  #
  # nixpkgs.config.permittedInsecurePackages = [
  #   "broadcom-sta-6.30.223.271-59-7.1.6"   # ajuste a string se o Nix reclamar
  # ];
  #
  # boot.blacklistedKernelModules = [ "b43" "brcmsmac" "bcma" "ssb" ];
  # boot.kernelModules = [ "wl" ];
  # boot.extraModulePackages = with config.boot.kernelPackages; [ broadcom_sta ];

  # ==================== GRAPHICS (Mesa/OpenGL) ====================
  # Sem isso, niri e o greeter (cage+regreet, ambos wlroots) não conseguem
  # criar contexto EGL/GBM e ficam mudos.
  hardware.graphics.enable = true;

  # Ferramentas de debug wireless (úteis só com o chip físico) +
  # Spotify: só neste host (não disponível p/ aarch64-linux das VMs UTM/Fusion)
  environment.systemPackages = lib.mkAfter (
    with pkgs; [
      iw
      wirelesstools
      spotify
      chirp
    ]
  );

  system.stateVersion = "26.05";
}
