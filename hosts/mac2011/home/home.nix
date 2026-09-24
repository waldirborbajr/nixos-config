# hosts/mac2011/home/home.nix
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
  ];

  xdg.configFile."niri/config/input.kdl".source = ../../../home/configs/niri/config/input-mac2011.kdl;
  xdg.configFile."niri/config/outputs.kdl".source = ../../../home/configs/niri/config/outputs-mac2011.kdl;
  xdg.configFile."waybar/output.jsonc".source = ../../../home/configs/waybar/output-mac2011.jsonc;
}
