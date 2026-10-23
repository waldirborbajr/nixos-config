# home/modules/nh.nix
#
# Só nh (Nix helper). Os parâmetros de limpeza vêm de home/configs/nh/nh.toml.
{
  config,
  lib,
  ...
}: let
  cfg = builtins.fromTOML (builtins.readFile ../configs/nh/nh.toml);
in {
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nixos-config";
    clean = {
      enable = cfg.clean.enable;
      extraArgs = lib.concatStringsSep " " [
        "--keep-since ${cfg.clean.keep_since}"
        "--keep ${toString cfg.clean.keep}"
      ];
    };
  };
}
