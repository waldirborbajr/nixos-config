# hosts/mac2011/home/modules/niri.nix
# Overrides de compositor só deste host: input e saída (tela do
# MacBook). O resto da config do niri é a compartilhada em
# home/modules/desktop.nix.
_: {
  xdg.configFile."niri/config/input.kdl".source = ../../../../home/configs/niri/config/input-mac2011.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../../home/configs/niri/config/outputs-mac2011.kdl;
}
