{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.apps.zsh.enable {
    home.file.".p10k.zsh" = {
      source = ./.p10k.zsh;
      force = true;
    };
  };
}
