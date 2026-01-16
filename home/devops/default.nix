{ userConfigs, ... }:

{
  imports = [
    ../common/core
    ../common/profiles/devops
    ../common/profiles/desktop
  ];

  home.stateVersion = "25.11";

  _module.args.userConfig = userConfigs.devops;
}
