{ pkgs, lib, config, ... }:

{
  ############################################
  # Commitizen
  ############################################
  home.packages = with pkgs; [
    commitizen
    nodePackages.cz-conventional-changelog
  ];

  ############################################
  # XDG config: ~/.config/commitizen/config.json
  ############################################
  xdg.configFile."commitizen/config.json".text = ''
    {
      "path": "cz-conventional-changelog"
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
