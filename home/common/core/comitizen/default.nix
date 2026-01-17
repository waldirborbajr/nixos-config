{ pkgs, config, lib, ... }:

{
  # Commitizen CLI
  home.packages = with pkgs; [
    commitizen
  ];

  # Alias opcional
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    cz = "cz";
    ccm = "cz commit";
  };
}
