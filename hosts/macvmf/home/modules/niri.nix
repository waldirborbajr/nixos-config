# hosts/macvmf/home/modules/niri.nix
# Overrides de compositor só deste host: input e saída (compartilhado
# com macutm via os mesmos arquivos -mac/-macvm). O resto da config do
# niri é a compartilhada em home/modules/desktop.nix.
_: {
  xdg.configFile."niri/config/input.kdl".source = ../../../../home/configs/niri/config/input-mac.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../../home/configs/niri/config/outputs-macvm.kdl;
}
