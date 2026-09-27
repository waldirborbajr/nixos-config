# hosts/dell1564/home/home.nix
# Entrada do home-manager pro Dell — wiring feito no flake.nix
# (home-manager.users.borba, um lugar só pra frota inteira). Overrides
# de hardware (input/outputs do niri, output da waybar pro teclado
# ABNT2 + tela interna) ficam aqui, não em configuration.nix.
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
  ];

  xdg.configFile."niri/config/input.kdl".source = ../../../home/configs/niri/config/input-dell.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../home/configs/niri/config/outputs-dell.kdl;
  xdg.configFile."waybar/output.jsonc".source = ../../../home/configs/waybar/output-dell.jsonc;
}
