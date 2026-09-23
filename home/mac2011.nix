# home/mac2011.nix
# Entrada do home-manager para o host mac2011. Hoje é só a camada de
# desktop (niri/waybar) — overrides de hardware (input/outputs do
# niri, output da waybar) continuam em hosts/mac2011/configuration.nix,
# aplicados por cima via home-manager.users.${username}.
{...}: {
  imports = [./home_niri.nix];
}
