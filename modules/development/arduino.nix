{
  config,
  lib,
  pkgs,
  ...
}:

# Convertido de devshells/arduino (nix develop). O devshell original usa um
# overlay (arduino-nix) para montar um arduino-cli com pacotes de placas
# (arduinoPackages.platforms.arduino.avr) já embutidos; aqui, pra manter o
# módulo simples e sem depender de inputs extras no flake, instalamos o
# arduino-cli "puro" do nixpkgs + avrdude. As placas AVR podem ser instaladas
# em runtime com `arduino-cli core install arduino:avr`.
{
  environment.systemPackages = with pkgs; [
    arduino-cli
    avrdude
  ];
}
