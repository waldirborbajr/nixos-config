# home/dell1564.nix
# Entrada do home-manager para o host dell1564. Hoje é só a camada de
# desktop (niri/waybar) — overrides de hardware (input/outputs do
# niri, output da waybar) continuam em hosts/dell1564/configuration.nix,
# aplicados por cima via home-manager.users.${username}.
{...}: {
  imports = [./home_niri.nix];
}
