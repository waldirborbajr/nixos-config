{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.ferretdb.enable {
    # FerretDB não possui um serviço NixOS nativo aqui. Mantemos os binários
    # disponíveis, enquanto o start/stop pode continuar sendo feito pelo
    # devshell ou manualmente.
    environment.systemPackages = with pkgs; [
      ferretdb
      mongosh
    ];
  };
}
