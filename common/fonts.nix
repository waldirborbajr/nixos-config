{ pkgs, ... }:

{
  fonts = {
    ############################################
    # Fontes instaladas no sistema
    ############################################
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
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
      };
    };

    ############################################
    # Evita instalar fontes padrão automaticamente
    ############################################
    enableDefaultFonts = false;
  };
}
