# home/macutm.nix
# Entrada do home-manager para o host macutm. Hoje é só a camada de
# desktop (niri/waybar) — overrides de hardware (input/outputs do
# niri, output da waybar) continuam em hosts/macutm/configuration.nix,
# aplicados por cima via home-manager.users.${username}.
{...}: {
  imports = [./home_niri.nix];
}
