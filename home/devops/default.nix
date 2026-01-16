{ userConfigs, ... }:

{
  imports = [
    ../common/core
  ];

  home.stateVersion = "25.11";

  _module.args.userConfig = userConfigs.devops;
}
