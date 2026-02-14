{
  config,
  lib,
  ...
}:
{
  config = lib.mkIf confg.apps.zsh.enable {
    imports = [
      ./zsh.nix
      ./zsh_alias.nix
      ./zsh_keybinds.nix
    ];
  };
}
