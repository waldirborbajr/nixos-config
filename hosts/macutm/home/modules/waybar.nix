# hosts/macutm/home/modules/waybar.nix
# Override de saída da waybar só deste host. O resto da config da
# waybar é a compartilhada em home/modules/desktop.nix.
_: {
  xdg.configFile."waybar/output.jsonc".source = ../../../../home/configs/waybar/output-macvm.jsonc;
}
