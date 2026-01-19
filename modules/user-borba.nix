{ pkgs, ... }:

{
  ############################################
  # User: borba
  ############################################
  users.users.borba = {
    isNormalUser = true;
    description = "BORBA JR W";
    shell = pkgs.zsh;

    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "libvirtd"
      "dialout"   # required for CHIRP / serial radios
    ];
  };

  ############################################
  # Passwordless sudo
  ############################################
  security.sudo.extraRules = [
    {
      users = [ "borba" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
