# system/modules/mac-vm.nix
#
# Quirks de VM por cima da família Mac (system/modules/mac-family.nix) —
# usado por macutm e macvmf. Cada host que importa este arquivo também
# precisa importar mac-family.nix (a dupla não é mais implícita como
# antes; ver hosts/macutm/configuration.nix e hosts/macvmf/configuration.nix).
# O agente de guest (UTM vs Fusion) e o hardware-configuration.nix
# continuam específicos de cada host.
{
  lib,
  pkgs,
  ...
}: {
  # ==================== BOOT (extras de VM) ====================
  boot.kernelParams = ["mitigations=off"]; # ajuda em VMs

  # ==================== GRAPHICS (VM / virtio-gpu) ====================
  # Necessário pro niri (Wayland) sob UTM/Fusion — evita tela preta
  # depois do login.
  hardware.graphics.enable = true;
  boot.kernelModules = [
    "virtio_gpu"
    "virtio_pci"
  ];

  # cage/regreet e niri via virtio-gpu geralmente precisam de renderer
  # por software (a aceleração 3D do virtio-gpu costuma ser instável
  # nesses hypervisors) — senão o greeter sai imediatamente / tela preta.
  # Só se aplica às VMs — mac2011/dell1564 têm GPU real e não precisam
  # disso (por isso este mkForce vive aqui, não em mac-family.nix).
  services.greetd.settings.default_session.command = lib.mkForce ''
    ${pkgs.dbus}/bin/dbus-run-session \
    env GSK_RENDERER=cairo WLR_NO_HARDWARE_CURSORS=1 WLR_RENDERER=pixman \
    ${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.regreet}
  '';
}
