# modules/apps/lazygit.nix
# Lazygit - Terminal UI for Git operations with custom configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.apps.lazygit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable lazygit terminal UI for git";
    };
  };

  config = lib.mkIf config.apps.lazygit.enable {
    home.packages = with pkgs; [
      lazygit # Terminal UI for git
    ];

    # Shell aliases
    programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
      lg = "lazygit";
    };

    # Lazygit configuration
    programs.lazygit = {
      enable = true;
      settings = {
        # Custom services (e.g., GitHub VGW)
        services = {
          "github-vgw" = "github:github.com";
        };

        # OS settings
        os = {
          edit = "nvim";
        };

        # GUI theme configuration (Catppuccin-inspired)
        gui = {
          theme = {
            activeBorderColor = [
              "#a6e3a1" # Green
              "bold"
            ];
            inactiveBorderColor = [
              "#cdd6f4" # Text
            ];
            optionsTextColor = [
              "#89b4fa" # Blue
            ];
            selectedLineBgColor = [
              "#313244" # Surface0
            ];
            cherryPickedCommitBgColor = [
              "#94e2d5" # Teal
            ];
            cherryPickedCommitFgColor = [
              "#89b4fa" # Blue
            ];
            unstagedChangesColor = [
              "red" # Red
            ];
          };
        };

        # Custom commands
        customCommands = [
          {
            key = "R";
            command = "git fetch upstream main && git rebase upstream/main && git push --force-with-lease";
            context = "localBranches";
          }
          {
            key = "<C-p>";
            command = "git add -A && git commit --allow-empty-message -m '' && git push";
            context = "localBranches";
          }
        ];

        # Skip when not in a git repository
        notARepository = "skip";
      };
    };
  };
}
