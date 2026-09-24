# system/overlays.nix
#
# Overlays de nixpkgs aplicados em todos os hosts NixOS. Hoje só o
# rust-overlay (pkgs.rust-bin, usado por system/modules/dev/rust.nix).
# Antes vivia inline no flake.nix; movido pra cá pra bater com a
# estrutura (system/overlays.nix é o único lugar de overlays).
{inputs, ...}: {
  nixpkgs.overlays = [
    inputs.rust-overlay.overlays.default
  ];
}
