# modules/networking.nix
# ---
{ config, lib, ... }:
{
  config = lib.mkIf config.system-config.networking.enable {
    networking.networkmanager.enable = true;

    systemd.services.NetworkManager-wait-online.enable = false;
  };
}
