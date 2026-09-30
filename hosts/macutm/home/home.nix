# hosts/macutm/home/home.nix
{...}: {
  imports = [
    ../../../home/profiles/desktop.nix
    ../../../home/profiles/x86/desktop.nix
    ./modules/niri.nix
    ./modules/waybar.nix
  ];
}
