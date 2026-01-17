{ pkgs, config, lib, ... }:

{
  programs.lazygit = {
    enable = true;

    settings = {
      git = {
        pager = {
          colorArg = "always";
          pager = "delta --color-only --dark --paging=never";
        };
      };

      customCommands = [
        {
          key = "C";
          context = "files";
          description = "Commitizen (cz-git)";
          command = "cz commit";
        }
      ];
    };
  };

  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    lg = "lazygit";
  };
}
