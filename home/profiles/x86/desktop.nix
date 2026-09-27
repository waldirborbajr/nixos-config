# home/profiles/x86/desktop.nix
#
# Apps/TUIs extras da sessão do usuário, opcionais — importado por
# mac2011, macutm e macvmf (não pelo Dell, que fica com só o núcleo em
# home/profiles/desktop.nix). Sem dependência de sistema própria (o
# gvfs que o Nemo precisa vem de system/modules/mac-family.nix).
# "x86" é o nome que a estrutura de referência usa pra "extras
# opcionais"; nada aqui depende de arquitetura de verdade.
{pkgs, ...}: {
  home.packages = with pkgs; [
    paprefs # preferências do pulseaudio
    pasystray # systray do pulseaudio
    pulsemixer # mixer de pulseaudio em TUI
    reaper # DAW (unfree; allowUnfree já ligado em system/profiles/base.nix)
    loupe # visualizador de imagens (GNOME)
    grimblast # screenshot helper (originado do Hyprland, empacotado standalone)
    libnotify # notify-send
    nemo # gerenciador de arquivos (gvfs continua como serviço de sistema)
    kooha # gravador de tela
  ];
}
