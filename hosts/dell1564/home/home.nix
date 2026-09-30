# hosts/dell1564/home/home.nix
# Entrada do home-manager pro Dell — wiring feito no flake.nix
# (home-manager.users.borba, um lugar só pra frota inteira). Overrides
# de hardware (input/outputs do niri, output da waybar pro teclado
# ABNT2 + tela interna) ficam em ./modules/, não em configuration.nix.
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];
}
