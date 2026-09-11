{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/ferretdb (nix develop). FerretDB não tem módulo
# NixOS nativo (services.ferretdb não existe no nixpkgs), então aqui só
# disponibilizamos os binários globalmente; o start/stop continua manual,
# igual ao shellHook original (ferret-start/ferret-stop viravam funções de
# shell lá — aqui é só `ferretdb` na mão, ou adapte pra um systemd.user.services
# se quiser automatizar).
{
  environment.systemPackages = with pkgs; [
    ferretdb
    mongosh
    sqlite # útil pra inspecionar o arquivo .sqlite diretamente
  ];
}
