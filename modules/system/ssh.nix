# modules/ssh.nix
# ---
## Relation truth

#{ ... }:
#
#{
#  services.openssh = {
#    enable = true;
#    openFirewall = true;
#
#    settings = {
#      PermitRootLogin = "no";
#      PasswordAuthentication = false;
#      KbdInteractiveAuthentication = false;
#    };
#  };
#}


## Aak for user and password

{ config, lib, ... }:

{
  config = lib.mkIf config.system-config.ssh.enable {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        KbdInteractiveAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };
}
