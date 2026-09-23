# home/home_niri.nix
# Camada de desktop (niri/waybar/mako + emacs-vanilla) por cima do
# perfil base — usada pelos 4 hosts NixOS (dell1564, mac2011, macutm,
# macvmf). O macbook NÃO importa este arquivo (sem Wayland/niri lá).
{...}: {
  imports = [
    ./home.nix
    ./emacs-vanilla.nix
    ./desktop.nix
  ];
}
