# hosts/mac2011/home/home.nix
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
    # ../../../home/modules/herdr.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];
}
