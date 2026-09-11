{
  config,
  lib,
  pkgs,
  ...
}:

{
  # MongoDB é unfree (SSPL). O allowUnfree é limitado ao pacote necessário
  # pelo módulo de desenvolvimento.
  nixpkgs.config.allowUnfree = true;

  services.mongodb = {
    enable = lib.mkDefault false;
    package = pkgs.mongodb;
    bind_ip = "127.0.0.1";
    dbpath = "/var/lib/mongodb";
  };

  environment.systemPackages = with pkgs; [
    mongosh
    mongodb
  ];
}
