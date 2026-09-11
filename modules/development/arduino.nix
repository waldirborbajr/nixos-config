{
  config,
  lib,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.development.languages.arduino.enable {
    # Ferramentas Arduino do devshell. O devshell original usava arduino-nix
    # para empacotar o core AVR dentro do arduino-cli. No módulo NixOS mantemos
    # os binários disponíveis; cores/boards podem ser instalados com
    # `arduino-cli core install arduino:avr` conforme o hardware/projeto.
    environment.systemPackages = with pkgs; [
      arduino-cli
      avrdude
    ];
  };
}
