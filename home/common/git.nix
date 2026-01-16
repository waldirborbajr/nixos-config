{ userConfigs, config, ... }:
let
  username   = config.home.username;
  userConfig = userConfigs.${username};
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        email = userConfig.email;
        name = userConfig.fullName;
      };
      pull.rebase = "true";
    };

    signing = {
      key = userConfig.gitKey;
      signByDefault = userConfig.gitKey != null;
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      keep-plus-minus-markers = true;
      light = false;
      line-numbers = true;
      navigate = true;
      width = 280;
    };
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}

