{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/mongodb (nix develop). O pacote mongodb é unfree
# (SSPL) — o devshell original já usava config.allowUnfree = true só pra
# esse import do nixpkgs; aqui setamos global porque services.mongodb
# precisa do pacote já resolvido no pkgs "de sistema".
{
  nixpkgs.config.allowUnfree = true;

  services.mongodb = {
    enable = true;
    package = pkgs.mongodb;
    bind_ip = "127.0.0.1";
    dbpath = "/var/lib/mongodb";
  };

  environment.systemPackages = with pkgs; [
    mongosh
  ];
}
