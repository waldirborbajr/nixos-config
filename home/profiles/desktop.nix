# home/profiles/desktop.nix
# Camada de desktop (niri/waybar/mako + emacs-vanilla + terminal
# gráfico + apps GTK), irmã de ./base.nix — não importa base.nix por
# dentro (mesmo padrão do ulyssecrn/nixos-config). Cada host importa
# os dois explicitamente, lado a lado, no seu home.nix. Usada pelos 4
# hosts NixOS (dell1564, mac2011, macutm, macvmf). O macbook NÃO
# importa este arquivo (sem Wayland/niri lá) — só
# home/profiles/base.nix (+ ../modules/alacritty.nix direto, já que
# ele ainda precisa de um terminal mesmo sem sessão niri).
{pkgs, ...}: {
  imports = [
    ../modules/emacs-vanilla.nix
    ../modules/desktop.nix
    ../modules/alacritty.nix
    # ../modules/wezterm.nix # terminal padrão continua Alacritty; ative se quiser trocar
  ];

  # Movidos de home/profiles/base.nix — dependem de sessão gráfica
  # (visualizador de PDF, gerenciador de arquivo GTK).
  home.packages = with pkgs; [
    # Fonts — Hack/Noto/emoji come from Stylix (font-packages target).
    noto-fonts-cjk-sans
    liberation_ttf                   # Arial/Times/Courier metric substitutes
    gyre-fonts                       # required by texlive
    
    # LaTeX
    texliveFull
    pandoc

    # Utilities
    brave
#    obsidian
#    nextcloud-client
#    libreoffice
    vlc
    pdfchain                         # pdf merger
#    veracrypt
#    obs-studio
#    calibre
#    tio    

    mupdf
    xarchiver
  ];
}
