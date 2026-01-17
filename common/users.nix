{ pkgs, userConfigs, ... }:

let
  mkUser = username: cfg: {
    isNormalUser = true;
    description = cfg.fullName;

    extraGroups = [
      "wheel"
    ]
    ++ (if cfg.role == "desktop" then [ "networkmanager" ] else [ ])
    ++ (if cfg.role == "devops" then [ "docker" ] else [ ]);
  };
in
{
  users.users = {
    borba = mkUser "borba" userConfigs.borba;
    devops = mkUser "devops" userConfigs.devops;
  };
}
