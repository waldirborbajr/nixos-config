# hosts/mac2011/home/home.nix
{pkgs, ...}: {
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
  home.packages = with pkgs; [
    darktable
    gnome-text-editor
    brave
    vlc
    # AnyDesk: o cliente GTK falha em "cannot open display :0" com
    # GDK_BACKEND=wayland (padrão da sessão). Forçar x11 só neste binário,
    # sem mudar a variável global.
    (pkgs.symlinkJoin {
      name = "anydesk-x11";
      paths = [pkgs.anydesk];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = "wrapProgram $out/bin/anydesk --set GDK_BACKEND x11";
    })
  ];
}
