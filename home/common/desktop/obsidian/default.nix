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

#{
# Se você quiser substituir o Obsidian padrão (ao invés de criar outro comando):
#{
#home.packages = [
#  (pkgs.symlinkJoin {
#    name = "obsidian";
#    paths = [ pkgs.obsidian ];
#    buildInputs = [ pkgs.makeWrapper ];
#    postBuild = ''
#      wrapProgram $out/bin/obsidian \
#        --add-flags "--enable-features=WaylandWindowDecorations" \
#        --add-flags "--ozone-platform=wayland"
#    '';
#  })
#];
#}
