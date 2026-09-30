# home/profiles/desktop.nix
# Camada de desktop (niri/waybar/mako + emacs-vanilla), irmã de
# ./base.nix — não importa base.nix por dentro (mesmo padrão do
# ulyssecrn/nixos-config). Cada host importa os dois explicitamente,
# lado a lado, no seu home.nix. Usada pelos 4 hosts NixOS (dell1564,
# mac2011, macutm, macvmf). O macbook NÃO importa este arquivo (sem
# Wayland/niri lá) — só home/profiles/base.nix.
{...}: {
  imports = [
    ../modules/emacs-vanilla.nix
    ../modules/desktop.nix
  ];
}
