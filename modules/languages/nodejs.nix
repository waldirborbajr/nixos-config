# modules/languages/nodejs.nix
# Consolidado: common + enable
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    nodejs_20
    nodePackages.pnpm
  ];

  environment.variables = {
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
  };

  environment.shellAliases = {
    ni = "pnpm install";
    nr = "pnpm run";
    nx = "pnpm dlx nx";
  };
}
