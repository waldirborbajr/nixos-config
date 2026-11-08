# hosts/mac2011/home/home.nix
{
  pkgs,
  pkgs-unstable,
  ...
}: {
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
  # vlc: vindo de home/profiles/desktop.nix + system/profiles/x86/desktop.nix
  # (estavam duplicados nos dois — agora só existem aqui, exclusivos do mac2011).
  #
  # brave, anydesk, spotify, telegram, chromium: agora via Flatpak
  # (flatpak.apps em hosts/mac2011/configuration.nix). LibreWolf segue como
  # navegador nativo do Nix.
  home.packages = with pkgs; [
    darktable
    gnome-text-editor
    librewolf
    vlc
    # ZapFast (cliente WhatsApp não oficial) — só mac2011, do nixpkgs-unstable.
    pkgs-unstable.zapfast
  ];
}
