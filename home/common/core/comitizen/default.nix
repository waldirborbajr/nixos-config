{ pkgs, lib, config, ... }:

{
  ############################################
  # Commitizen + cz-git
  ############################################
  home.packages = with pkgs; [
    commitizen
    nodePackages.cz-git
  ];

  ############################################
  # XDG config: ~/.config/commitizen/config.json
  ############################################
  xdg.configFile."commitizen/config.json".text = ''
    {
      "path": "cz-git",
      "useEmoji": true
    }
  '';

  ############################################
  # Aliases
  ############################################
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    cz  = "cz";
    ccm = "cz commit";
  };
}
