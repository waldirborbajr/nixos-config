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

      # 🔕 Nunca assinar automaticamente
      commit.gpgSign = false;

      # Apenas declara o backend (não ativa)
      gpg.program = "gpg";
    };

    # 🚫 NÃO declare signing se não for usar
    # signing = { ... };  <-- removido
  };
}
