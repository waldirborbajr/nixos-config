{ pkgs, ... }:

{
  users.groups = {
    borba = {};
    devops = {};
  };

  users.users = {
    borba = {
      isNormalUser = true;
      description  = "Borba Jr W";
      group        = "borba";
      extraGroups  = [ "wheel" "networkmanager" "docker" ];
      shell        = pkgs.zsh;
    };

    devops = {
      isNormalUser = true;
      description  = "DevOps User";
      group        = "devops";
      extraGroups  = [ "wheel" "docker" ];
      shell        = pkgs.zsh;
    };
  };
}

