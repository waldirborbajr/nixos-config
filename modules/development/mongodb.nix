{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.mongodb.enable {
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
  };
}
