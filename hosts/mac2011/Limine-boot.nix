# hosts/mac2011/boot.nix
{lib, ...}: {
  # ==================== BOOTLOADER: LIMINE (teste) ====================
  # Substitui o systemd-boot da mac-family.nix SÓ neste host.
  # Limine em modo removível (EFI/BOOT/BOOTX64.EFI): o firmware Apple
  # ignora entradas de NVRAM criadas pelo Linux, então o caminho
  # removível é o que costuma subir no Option-key boot picker.
  # Sem Secure Boot (MacBook 2011 não tem).
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # ---- systemd-boot (anterior, referência) ----
  # Vinha de system/modules/mac-family.nix:
  #   boot.loader.systemd-boot.enable = true;
  #   boot.loader.efi.canTouchEfiVariables = true;
  # Para voltar: remova o bloco limine acima e descomente essas linhas
  # (ou apague as duas linhas mkForce e deixe o mac-family.nix valer).

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
