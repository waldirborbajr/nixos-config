# Sobrescreve o boot.loader do configuration.nix compartilhado, específico pro Dell (legacy BIOS)
boot.loader.systemd-boot.enable = lib.mkForce false;
boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
boot.loader.grub = {
  enable = true;
  device = "/dev/sda"; # ajuste pro disco real do Dell — confirme com `lsblk`
};
