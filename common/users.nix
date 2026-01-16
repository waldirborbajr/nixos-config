# { pkgs, ... }:

# {
#   users.groups = {
#     borba = {};
#     devops = {};
#   };

#   users.users = {
#     borba = {
#       isNormalUser = true;
#       description  = "Borba Jr W";
#       group        = "borba";
#       extraGroups  = [ "wheel" "networkmanager" "docker" ];
#       shell        = pkgs.zsh;
#     };

#     devops = {
#       isNormalUser = true;
#       description  = "DevOps User";
#       group        = "devops";
#       extraGroups  = [ "wheel" "docker" ];
#       shell        = pkgs.zsh;
#     };
#   };
# }

{ pkgs, userConfigs, ... }:

let
  mkUser = username: cfg: {
    isNormalUser = true;
    description = cfg.fullName;
    shell = pkgs.zsh;

    extraGroups =
      [ "wheel" ]
      ++ (if cfg.role == "desktop" then [ "networkmanager" ] else [])
      ++ (if cfg.role == "devops"  then [ "docker" "podman" ] else []);
  };
in
{
  users.users = {
    borba  = mkUser "borba"  userConfigs.borba;
    devops = mkUser "devops" userConfigs.devops;
  };
}
