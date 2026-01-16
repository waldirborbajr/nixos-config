{ config, pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;

    # Melhor performance e compatibilidade
    storageDriver = "overlay2";
    enableOnBoot = true;
  };

  # Opcional, mas recomendado
  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "weekly";
  };
}
