# hosts/mac2011/home/home.nix
{
  pkgs,
  pkgs-unstable,
  ...
}: let
  # AnyDesk: o tarball servido em download.anydesk.com mudou sem que o
  # nixpkgs tivesse atualizado o hash esperado (hash mismatch em
  # anydesk-8.1.0-amd64.tar.gz). Sobrescrevemos o hash do src para o
  # valor real do arquivo atual.
  #
  # Como obter o hash correto:
  #   nix-prefetch-url https://download.anydesk.com/linux/anydesk-8.1.0-amd64.tar.gz
  #   nix hash convert --hash-algo sha256 --to sri <hash-base32>
  #
  # Substitua o valor abaixo pelo hash SRI retornado.
  anydeskFixed = pkgs.anydesk.overrideAttrs (old: {
    src = old.src.override {
      hash = "sha256-zS5P2eyTHZY7cBW8mQ2Q6M0lXcx9VZZTtpG3Bb6u7IQ=";
    };
  });
in {
  imports = [
    ../../../home/profiles/base.nix
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
    # ../../../home/modules/herdr.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];

  # ==================== NEOVIM (só mac2011) ====================
  # nightly = true → neovim-nightly-overlay (master do Neovim, versão
  # mais recente que o nixpkgs estável). Trocar pra false pega o
  # neovim do nixpkgs-unstable pinado no flake.lock.
  editors.neovim = {
    enable = true;
    nightly = true;
  };

  # ==================== PACOTES EXCLUSIVOS DESTE HOST ====================
  # darktable: vindo de hosts/macbook/home/home.nix.
  # brave/vlc: vindo de home/profiles/desktop.nix + system/profiles/x86/desktop.nix
  # (estavam duplicados nos dois — agora só existem aqui, exclusivos do mac2011).
  #
  # brave: REMOVIDO do nixpkgs unstable/26.05. Substitutos:
  #   - LibreWolf nativo (abaixo), mantido oficialmente no nixpkgs; ou
  #   - Flatpak com.brave.Browser (services.flatpak.enable = true no
  #     configuration.nix e "flatpak install flathub com.brave.Browser").
  # Aqui fica LibreWolf como padrão; troque por brave via Flatpak se preferir.
  home.packages = with pkgs; [
    darktable
    gnome-text-editor
    librewolf
    vlc
    # AnyDesk: o cliente GTK falha em "cannot open display :0" com
    # GDK_BACKEND=wayland (padrão da sessão). Forçar x11 só neste binário,
    # sem mudar a variável global. Usa anydeskFixed (hash corrigido) acima.
    (pkgs.symlinkJoin {
      name = "anydesk-x11";
      paths = [anydeskFixed];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/anydesk --set GDK_BACKEND x11";
    })
    # ZapFast (cliente WhatsApp não oficial) — só mac2011, do nixpkgs-unstable.
    pkgs-unstable.zapfast
  ];
}
