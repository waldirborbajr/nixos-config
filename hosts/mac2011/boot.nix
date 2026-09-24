# hosts/mac2011/boot.nix
_: {
  # Boot EFI comum (systemd-boot) já vem de system/modules/mac-family.nix.

  # ==================== WIRELESS (open-source b43) ====================
  # BCM4331 do MacBook Pro 2011 funciona com o driver open-source b43.
  # Evita o broadcom-sta (proprietário, inseguro e quebrando em kernel ≥ 7.1).
  # hardware.enableRedistributableFirmware = true; vem de
  # system/modules/broadcom-wifi.nix — compartilhado só com dell1564, o
  # outro host Broadcom físico.
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
}
