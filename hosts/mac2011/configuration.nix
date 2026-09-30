# hosts/mac2011/configuration.nix
# MacBook Pro 2011 — hardware físico Apple (x86_64)
#
# Programas / browsers / teclado / boot EFI → system/modules/mac-family.nix
# Extras opcionais (media, DAW, brave...) → system/profiles/x86/desktop.nix
# Wi-Fi/firmware → boot.nix
# Aqui só o que é específico deste hardware e não é boot.
{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ../../system/profiles/base.nix
    ../../system/profiles/desktop.nix
    ../../system/profiles/x86/desktop.nix
    ../../system/modules/mac-family.nix
    ../../system/modules/broadcom-wifi.nix

    # Containers — só mac2011. Descomente pra ativar (independentes entre si):
    # ../../system/profiles/x86/docker.nix
    # ../../system/profiles/x86/podman.nix
    # ../../system/profiles/x86/kubernetes.nix # k3d/kubectl/k9s — precisa de docker OU podman
  ];

  # O módulo hardware.bluetooth do NixOS força General.ControllerMode =
  # "dual" como default (sempre, mesmo sem configurar nada). O
  # controlador Broadcom interno do mac2011 é BR/EDR clássico puro, sem
  # LE de verdade. Testando "bredr" explícito.
  hardware.bluetooth.settings.General.ControllerMode = lib.mkForce "bredr";

  # ==================== GRAPHICS (Mesa/OpenGL) ====================
  # Sem isso, niri e o greeter (cage+regreet, ambos wlroots) não conseguem
  # criar contexto EGL/GBM e ficam mudos.
  hardware.graphics.enable = true;

  # ==================== DEV LANGUAGES ====================
  # Toolchains via system/modules/dev.nix (development.languages.<x>.enable).
  development.languages = {
    # ── Ativas ──
    go.enable = true;
    rust.enable = true;
    sqlite.enable = true;

    # ── Disponíveis (desligadas) ──
    nix.enable = false;
    python.enable = false;
    lua.enable = false;
    arduino.enable = false;
    latex.enable = false;
    postgresql.enable = false;
    mariadb.enable = false;
    mongodb.enable = false;
    ferretdb.enable = false;
  };

  # Ferramentas de debug wireless (úteis só com o chip físico)
  # Spotify/Chromium saíram daqui — movidos pra home/profiles/desktop.nix
  # (compartilhados pelos 4 hosts NixOS agora, não só mac2011).
  environment.systemPackages = lib.mkAfter (
    with pkgs; [
      iw
      wirelesstools
      chirp

      # Utilitários de terminal / infra (só mac2011, pra avaliar)
      magic-wormhole-rs # envio seguro de arquivos entre hosts
      ripgrep-all # rga: ripgrep em PDF/zip/docx etc
      iperf3 # throughput de rede entre hosts
      tcpdump # captura de pacotes (precisa de sudo)
      whois
      pwgen
      libqalculate # qalc: calculadora com conversão de unidades
    ]
  );

  system.stateVersion = "26.05";
}
