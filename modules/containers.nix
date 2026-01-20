{ config, pkgs, lib, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  users.users.borba.linger = true;

  networking.firewall.trustedInterfaces = [ "podman0" ];
  networking.firewall.allowedTCPPorts = [ 6443 ];
}
