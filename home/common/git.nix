{ userConfigs, config, ... }:
let
  username   = config.home.username;
  userConfig = userConfigs.${username};
in
{
  programs.git = {
    enable = true;

    userName  = userConfig.fullName;
    userEmail = userConfig.email;

    extraConfig = {
      pull.rebase = true;
    };

    signing = {
      key = userConfig.gitKey;
      signByDefault = userConfig.gitKey != null;
    };
  };

  programs.delta = {
    enable = true;
    options = {
      line-numbers = true;
      navigate = true;
    };
  };

  # Enable catppuccin theming for git delta
  catppuccin.delta.enable = true;
}

