{ pkgs, ... }:

{
  home.packages = [
    pkgs.obsidian

    # Wrapper Wayland para Obsidian
    (pkgs.writeShellScriptBin "obsidian-wayland" ''
      exec ${pkgs.obsidian}/bin/obsidian \
        --enable-features=WaylandWindowDecorations \
        --ozone-platform=wayland "$@"
    '')
  ];
}
