{ pkgs, lib, config, ... }:
{
  ############################################
  # Commitizen
  ############################################
  home.packages = with pkgs; [
    commitizen
  ];

  ############################################
  # XDG config: ~/.config/commitizen/config.json
  ############################################
  xdg.configFile."commitizen/config.json".text = ''
    {
      "name": "cz_conventional_commits"
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
