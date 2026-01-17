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
  # .czrc (global, declarativo)
  ############################################
  home.file.".czrc".text = ''
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
