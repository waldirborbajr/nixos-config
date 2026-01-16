{ pkgs, ... }:

{
  users.groups = {
    borba = {};
    devops = {};
  };

  users.users = {
    borba = {
      isNormalUser = true;
      group = "borba";
      description = "BORBA JR W";
      shell = pkgs.zsh;

      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
    };

    devops = {
      isNormalUser = true;
      group = "devops";
      description = "DevOps";
      shell = pkgs.zsh;

      extraGroups = [
        "wheel"
        "docker"
      ];
    };
  };
}

