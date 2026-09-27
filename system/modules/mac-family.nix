# system/modules/mac-family.nix
#
# Base compartilhada por TODOS os hosts da família Mac (mac2011 físico +
# macutm/macvmf VMs): boot EFI, teclado US/Mac, gvfs e Firefox
# Developer Edition. Programas pesados/opcionais foram pra
# system/profiles/x86/desktop.nix; quirks de VM (virtio, mitigations)
# pra system/modules/mac-vm.nix; Broadcom físico (só mac2011, não as
# VMs) pra system/modules/broadcom-wifi.nix.
{pkgs, ...}: {
  # ==================== BOOT (EFI comum a 2011 + VMs) ====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==================== KEYBOARD ====================
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "mac";

  # ==================== FILE MANAGER (Nemo) ====================
  # Sem o gvfs, o Nemo não consegue mandar arquivos pra lixeira: a tecla
  # Delete simplesmente não faz nada (falha silenciosa, sem erro na tela).
  services.gvfs.enable = true;

  # Firefox Developer Edition como binário `firefox` padrão (família Mac;
  # o Dell usa o Firefox estável, ver hosts/dell1564/configuration.nix).
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
  };
}
