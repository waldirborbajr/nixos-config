{ pkgs, ... }:

{
  fonts = {
    ############################################
    # Fontes instaladas no sistema
    ############################################
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts-emoji
    ];

    ############################################
    # Fontconfig
    ############################################
    fontconfig = {
      enable = true;

      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
        ];

        emoji = [
          "Noto Color Emoji"
        ];
      };
    };

    ############################################
    # Não instalar defaults automáticos
    ############################################
    enableDefaultFonts = false;
  };
}
