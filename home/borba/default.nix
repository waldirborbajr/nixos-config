{ userConfigs, ... }:

{
  imports = [
    ../common/core
    ../common/devtools
    ../common/desktop
  ];

  home.stateVersion = "25.11";

  _module.args.userConfig = userConfigs.borba;
}
