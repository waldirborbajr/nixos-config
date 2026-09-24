# hosts/macvmf/home/home.nix
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
  ];

  xdg.configFile."niri/config/input.kdl".source = ../../../home/configs/niri/config/input-mac.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../home/configs/niri/config/outputs-macvm.kdl;
  xdg.configFile."waybar/output.jsonc".source = ../../../home/configs/waybar/output-macvm.jsonc;
}
