# modules/nixos/hardware-quirks.nix
#
# nix-ld (binários dinâmicos genéricos) e bluetooth. Extraído 1:1 de
# configuration.nix (split cirúrgico, sem mudança de comportamento) —
# comentários de troubleshooting preservados porque documentam decisões
# já tomadas (não repetir experimentos já descartados).
{pkgs, ...}: {
  # ==================== NIX-LD ====================
  # Permite rodar binários dinâmicos genéricos de Linux (ex.: RadioManager
  # de CPS de rádio, instaladores .run, etc.) que esperam um ld-linux.so e
  # libs em /lib, coisa que o NixOS não tem fora da Nix store.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib
      libusb1 # acesso USB direto (CPS de rádio, programadores)
      udev
      icu # runtime .NET (RadioManager e outros CPS baseados em .NET)
      fontconfig # SkiaSharp (UI gráfica do RadioManager) precisa pra achar fontes
      freetype
      harfbuzz
    ];
  };

  # ==================== BLUETOOTH ====================
  # Voltado ao estado mínimo original. Testamos disable_ertm=1 (quebrou
  # setsockopt do bluetoothd), Policy.AutoEnable/ReconnectAttempts/
  # JustWorksRepairing (suspeito de brigar com pareamento manual em
  # background) e regra de udev de autosuspend — nenhum resolveu, e o
  # usuário confirmou que o MESMO hardware pareia sem problema no Fedora
  # com bluez "de fábrica". Ou seja: quanto menos customização aqui,
  # mais perto do baseline que sabemos que funciona.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;
}
