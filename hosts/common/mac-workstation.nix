# hosts/common/mac-workstation.nix
#
# Base compartilhada por TODOS os hosts Mac:
#   - mac2011  (hardware físico)
#   - macutm   (VM UTM)
#   - macvmf   (VM VMware Fusion)
#
# Aqui fica a instalação de programas, teclado US/Mac e browsers.
# Específicos de VM (podman, virtio, mitigations, guest tools) e de
# hardware físico (Broadcom wl, insecure packages) ficam nos módulos
# filhos — assim uma novidade de programa se configura uma única vez.
{ lib, pkgs, pkgs-unstable, common, inputs, ... }:
let
  inherit (common) username;
in {
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

  # ==================== PACKAGES ====================
  # Lista única para a família Mac. Dell continua com a lista própria (mais leve).
  environment.systemPackages = with pkgs; [
    zellij yazi jq just duf psmisc asciinema
    lazygit jujutsu lazyjj
    nitch

    flameshot vlc

    emacs emacsPackages.vterm emacsPackages.pbcopy

    dex autorandr xkill

    brightnessctl playerctl pciutils pavucontrol ffmpeg

    # build / containers CLI (o daemon podman em si só nas VMs)
    podman lazydocker gcc gnumake cmake gdb glibc libgcc libcxx

    lua-language-server stylua
    taplo marksman
  ]
  # ---- Áudio (pulseaudio/DAW) — confirmados em nixpkgs ----
  ++ [
    paprefs    # preferências do pulseaudio
    pasystray  # systray do pulseaudio
    pulsemixer # mixer de pulseaudio em TUI
    reaper     # DAW (unfree; allowUnfree já está ligado em configuration.nix/flake.nix)
    # spotify: NÃO fica aqui. Só existe binário oficial p/ x86_64-linux,
    # x86_64-darwin e aarch64-darwin (não há build p/ aarch64-linux, caso do
    # macutm/macvmf). Além disso o pedido é usar Spotify só no mac2011 —
    # ver hosts/mac2011/default.nix.
  ]
  # ---- Desktop/Wayland extras — confirmados em nixpkgs ----
  ++ [
    loupe               # visualizador de imagens (GNOME)
    grim                # screenshots
    grimblast           # screenshot helper (originado do Hyprland, mas empacotado standalone)
    libnotify           # notificações (notify-send)
    mpvpaper            # vídeo como wallpaper
    nemo                # gerenciador de arquivos
    networkmanagerapplet # applet de rede na systray
    wl-clipboard        # clipboard Wayland
    kooha               # gravador de tela
    hyprlax             # dynamic/parallax wallpaper daemon (confirmado no nixos-26.05)
    satty               # anotação de screenshot
    pear-desktop        # youtube music com suporte a mpris
    snitch              # inspeciona conexões de rede
    wooz                # zoom / magnifier utility
  ]
  # ---- Só existem na nixos-unstable até agora ----
  ++ (with pkgs-unstable; [
    diskonaut-ng # TUI de espaço em disco
    handy        # speech to text (app tauri/rust)
  ])
  # ---- Browsers (família Mac) ----
  ++ [
    brave                 # Chromium-based (unfree; allowUnfree já ligado)
  ];

  # ---- NÃO adicionados: exigem flake input / overlay que este repo ainda não tem ----
  #   nfsm, nfsm-cli      -> flake "github:gvolpe/nfsm"
  #   niri-scratchpad     -> flake "github:gvolpe/niri-scratchpad"
  #   nsticky, hyprlax-toggle, mpvpaper-toggle, dnix, pkgs.video-scripts.*

  # Firefox Developer Edition como binário `firefox` padrão
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
  };

  # ==================== VICINAE (launcher, mac2011 + VMs) ====================
  # Raycast-like launcher for Linux, native C++/Qt. Only wired here — this
  # file is shared by mac2011/macutm/macvmf, and NOT imported by dell1564.
  home-manager.users.${username} = {
    imports = [ inputs.vicinae.homeManagerModules.default ];
    programs.vicinae.enable = true;
  };
}