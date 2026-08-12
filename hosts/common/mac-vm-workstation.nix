# hosts/common/mac-vm-workstation.nix
#
# Base compartilhada pelas VMs Mac (macutm e macvmf). Só o agente de guest
# da VM (UTM vs VMware Fusion) e o hardware-configuration.nix continuam
# específicos de cada host — o resto é idêntico entre os dois.
{ lib, pkgs, common, ... }:
let
  inherit (common) username;
  # Local configs now live inside the flake (fase 3)
  niriInput   = ../../home/configs/niri/config/input-mac.kdl;
  niriOutputs = ../../home/configs/niri/config/outputs-macvm.kdl;
in {
  # ==================== BOOT ====================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "mitigations=off" ]; # ajuda em VMs

  # ==================== CONTAINERS ====================
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  virtualisation.containers.enable = true;

  # ==================== KEYBOARD ====================
  console.keyMap = "us";
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "mac";

  # ==================== PACKAGES ====================
  environment.systemPackages = with pkgs; [
    zellij yazi jq just duf psmisc asciinema
    lazygit jujutsu lazyjj

    flameshot vlc

    emacs emacsPackages.vterm emacsPackages.pbcopy

    dex autorandr xkill

    brightnessctl playerctl pciutils pavucontrol ffmpeg

    podman lazydocker gcc gnumake cmake gdb glibc libgcc libcxx

    rust-analyzer rustfmt
    lua-language-server stylua
    gotools golangci-lint-langserver

    python3Packages.python-lsp-server black taplo marksman
  ]
  # ---- Áudio (pulseaudio/DAW) — confirmados em nixpkgs ----
  ++ [
    paprefs    # preferências do pulseaudio
    pasystray  # systray do pulseaudio
    pulsemixer # mixer de pulseaudio em TUI
    reaper     # DAW (unfree; allowUnfree já está ligado em configuration.nix/flake.nix)
    # playerctl e pavucontrol já estão na lista acima, não duplicados
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
    diskonaut-ng        # TUI de espaço em disco
    hyprlax             # dynamic/parallax wallpaper daemon (confirmado no nixos-26.05, não precisa de pkgs-unstable)
    satty               # anotação de screenshot (nixpkgs usa "satty", não "satty-shot")
    handy               # speech to text (app tauri/rust)
    pear-desktop        # youtube music com suporte a mpris
    snitch              # inspeciona conexões de rede
    wooz                # zoom / magnifier utility
  ];

  # ---- NÃO adicionados: exigem flake input / overlay que este repo ainda não tem ----
  # As linhas abaixo ficam comentadas de propósito — adicionar como está quebraria o
  # `nixos-rebuild` (atributo inexistente em pkgs). Confirmei via busca que pelo menos
  # nfsm e niri-scratchpad são flakes separados do gvolpe, não pacotes de nixpkgs:
  #
  #   nfsm, nfsm-cli      -> flake "github:gvolpe/nfsm" (não está em flake.nix ainda)
  #   niri-scratchpad     -> flake "github:gvolpe/niri-scratchpad" (idem)
  #   nsticky             -> ferramenta de terceiros para niri, não encontrada em nixpkgs
  #   hyprlax-toggle      -> parece script complementar do próprio hyprlax, não é pacote nixpkgs
  #   mpvpaper-toggle     -> idem, provável script/overlay pessoal
  #   dnix                -> parece ser o instalador da Determinate Systems, não um atributo de pkgs
  #   pkgs.video-scripts.* (compression/recording/trimming/extractFrame)
  #                       -> namespace customizado, não existe em nixpkgs
  #
  # Se você tem um overlay ou flake próprio que fornece isso, me avisa que eu adiciono
  # o input no flake.nix e habilito essas linhas.

  programs.firefox.enable = lib.mkDefault true;

  # ==================== GRAPHICS (VM / virtio-gpu) ====================
  # Required for niri (Wayland) under UTM / Fusion — avoids black screen after login.
  hardware.graphics.enable = true;
  boot.kernelModules = [ "virtio_gpu" "virtio_pci" ];

  # ==================== HOME MANAGER (host-specific, fase 3) ====================
  # Override niri input + outputs for Mac keyboard/trackpad and Virtual-1 display.
  home-manager.users.${username} = {
    xdg.configFile."niri/config/input.kdl".source   = niriInput;
    xdg.configFile."niri/config/outputs.kdl".source = niriOutputs;
    xdg.configFile."waybar/output.jsonc".source     = ../../home/configs/waybar/output-macvm.jsonc;
  };
}
