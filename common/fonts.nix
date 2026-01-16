# { pkgs, ... }:

# {
#   fonts = {
#     packages = with pkgs; [
#       nerd-fonts.jetbrains-mono
#       nerd-fonts.terminess-ttf
#       nerd-fonts.blex-mono
#       ibm-plex
#       openmoji-color
#     ];

#     fontconfig.defaultFonts = {
#       monospace = [ "JetBrainsMono Nerd Font" ];
#       sansSerif = [ "IBM Plex Sans" ];
#       serif = [ "IBM Plex Serif" ];
#       emoji = [ "OpenMoji Color" ];
#     };

#     enableDefaultFonts = true;
#   };
# }

{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      # ── Monospace (Dev)
      nerd-fonts.jetbrains-mono

      # ── UI / Texto
      ibm-plex

      # ── Fallback universal (MUITO IMPORTANTE)
      dejavu_fonts
      liberation_ttf

      # ── Unicode / Símbolos / CJK
      noto-fonts
      noto-fonts-cjk
      noto-fonts-extra

      # ── Emoji
      openmoji-color
      noto-fonts-emoji
    ];

    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "DejaVu Sans Mono"
        ];

        sansSerif = [
          "IBM Plex Sans"
          "Noto Sans"
          "DejaVu Sans"
        ];

        serif = [
          "IBM Plex Serif"
          "Noto Serif"
          "DejaVu Serif"
        ];

        emoji = [
          "OpenMoji Color"
          "Noto Color Emoji"
        ];
      };

      # Renderização melhor (especialmente em Wayland)
      hinting.enable = true;
      hinting.style = "slight";

      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };

    enableDefaultFonts = false;
  };
}
