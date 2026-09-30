# hosts/dell1564/home/modules/niri.nix
# Overrides de compositor só deste host: input (teclado ABNT2) e saída
# (tela interna). O resto da config do niri é a compartilhada em
# home/modules/desktop.nix.
_: {
  xdg.configFile."niri/config/input.kdl".source = ../../../../home/configs/niri/config/input-dell.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../../home/configs/niri/config/outputs-dell.kdl;
}
