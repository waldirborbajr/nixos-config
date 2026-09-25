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

    ./services/wireguard.nix
    ./services/sabnzbd.nix
    ./services/qbittorrent.nix
    ./services/radarr.nix
    ./services/sonarr.nix
    ./services/prowlarr.nix
    ./services/seerr.nix
    ./services/immich.nix
    ./services/nextcloud.nix
    ./services/paperless.nix
    ./services/calibre.nix
    ./services/matrix.nix
    ./services/monitoring.nix
    ./services/zed.nix
    ./services/tracearr.nix
    ./services/protonvpn-fr.nix
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

  # ── SSH ─────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # ── Tailscale (base.nix enables it; atilla advertises LAN + exit node)
  services.tailscale = {
    useRoutingFeatures = "server";
    openFirewall = true;
    extraSetFlags = [
      "--advertise-routes=10.10.10.0/24"
      "--advertise-exit-node"
    ];
  };

  system.stateVersion = "26.05";
}
