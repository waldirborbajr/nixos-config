# hosts/macutm/default.nix
{ pkgs, ... }:
{
  imports = [ ../common/mac-vm-workstation.nix ];

  # UTM (Apple Silicon) — agente de clipboard compartilhado com o host
  environment.systemPackages = [ pkgs.spice-vdagent ];
}
