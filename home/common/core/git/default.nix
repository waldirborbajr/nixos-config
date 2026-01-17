{
  pkgs,
  userConfigs,
  config,
  lib,
  ...
}:

let
  username = config.home.username;
  userConfig = userConfigs.${username};
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = userConfig.fullName;
        email = userConfig.email;
      };

      pull.rebase = true;
      init.defaultBranch = "main";

      gpg.program = "gpg";

      commit.gpgSign = userConfig.gitKey != null;
    };

    signing = lib.mkIf (userConfig.gitKey != null) {
      key = "${userConfig.gitKey}!";
      signByDefault = true;
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

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    enableZshIntegration = true;
    defaultCacheTtl = 1800;
    maxCacheTtl = 7200;
    pinentryPackage = pkgs.pinentry-curses;
  };

  catppuccin.delta.enable = true;
}
