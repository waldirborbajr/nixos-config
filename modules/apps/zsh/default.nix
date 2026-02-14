{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf config.apps.zsh.enable {
    imports = [
      ./zsh.nix
      ./zsh_alias.nix
      ./zsh_keybinds.nix
    ];
  };
}
