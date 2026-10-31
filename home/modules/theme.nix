# home/modules/theme.nix
#
# Paleta base16 central (nix-colors), Nord. Os módulos leem
# config.colorScheme.palette.baseXX. Arquivos raw (ex.: tmux.conf) passam
# por renderTheme: troca o hex do esquema-fonte (nord) pelo hex do esquema
# atual. Trocar de tema = mudar colorScheme abaixo.
{
  config,
  inputs,
  ...
}: let
  source = inputs.nix-colors.colorSchemes.nord.palette;
  keys = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  from = map (k: "#${source.${k}}") keys;
  to = map (k: "#${config.colorScheme.palette.${k}}") keys;
in {
  imports = [inputs.nix-colors.homeManagerModules.default];

  colorScheme = inputs.nix-colors.colorSchemes.nord;

  _module.args.renderTheme = text: builtins.replaceStrings from to text;
}
