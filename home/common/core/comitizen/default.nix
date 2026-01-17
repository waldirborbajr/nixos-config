{ pkgs, lib, config, ... }:

{
  home.packages = with pkgs; [
    commitizen
    nodePackages.cz-git
  ];

  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    cz  = "cz";
    ccm = "cz commit";
  };
}
