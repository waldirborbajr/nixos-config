# modules/features/devops.nix
{ lib, devopsEnabled ? false, ... }:

{
  virtualisation.docker.enable = lib.mkDefault false;
  services.k3s.enable = lib.mkDefault false;

  config = lib.mkIf devopsEnabled {
    virtualisation.docker.enable = true;
    virtualisation.docker.enableOnBoot = true;
    services.k3s.enable = true;
  };
}
