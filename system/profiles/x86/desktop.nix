# system/profiles/x86/desktop.nix
#
# Pacotes de sistema opcionais/pesados — importado por mac2011, macutm e
# macvmf, e deliberadamente NÃO pelo dell1564 (mantém o Dell leve, é a
# máquina mais lenta da frota). "x86" aqui é o nome que a estrutura de
# referência usa pra "extras opcionais de desktop", não uma restrição
# de arquitetura de verdade — nada aqui depende de x86_64 (macutm/macvmf
# são aarch64-linux e importam este mesmo arquivo sem problema).
{
  pkgs,
  pkgs-unstable,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      duf
      psmisc
      nitch
      leaf
      ghgrab
      kew

      flameshot
      vlc

      dex
      autorandr
      xkill

      # build / containers CLI (o daemon podman em si é opt-in separado,
      # ver x86/containers.nix)
      podman
      lazydocker
      libgcc
      libcxx
    ]
    ++ [
      # mpvpaper: niri usa swaybg pra wallpaper, mpvpaper ficou sem uso —
      # candidato a corte, mantido por enquanto.
      mpvpaper
      hyprlax # dynamic/parallax wallpaper daemon
      satty # anotação de screenshot (já tem swappy — candidato a corte)
      pear-desktop # youtube music com suporte a mpris
      snitch # inspeciona conexões de rede
      wooz # zoom / magnifier utility
    ]
    ++ (with pkgs-unstable; [
      diskonaut-ng # TUI de espaço em disco
      handy # speech to text (app tauri/rust)
      lazyrsync
    ])
    ++ [
      brave # Chromium-based (unfree; allowUnfree já ligado em base.nix)
    ];
}
