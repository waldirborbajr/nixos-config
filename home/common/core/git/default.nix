{
  pkgs,
  userConfigs,
  config,
  lib,
  ...
}:

let
  username   = config.home.username;
  userConfig = userConfigs.${username};
in
{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name  = userConfig.fullName;
        email = userConfig.email;
      };

      pull.rebase = true;
      init.defaultBranch = "main";

      # ❌ Nunca assinar automaticamente
      commit.gpgSign = false;

      # Apenas informa qual GPG usar (não ativa signing)
      gpg.program = "gpg";
    };

    # ❌ Remove qualquer signing implícito
    signing = lib.mkForce null;
  };
}
