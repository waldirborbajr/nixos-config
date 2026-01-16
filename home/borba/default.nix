{ userConfigs, ... }:

{
  imports = [
    ../common
  ];

  _module.args.userConfig = userConfigs.borba;
}

