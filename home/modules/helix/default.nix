# home/modules/helix/default.nix
#
# Helix configurado a partir dos arquivos TOML crus em home/configs/helix/
# (linkados via xdg.configFile), não mais gerado a partir de atributos Nix.
# programs.helix aqui só instala o pacote/binário; toda configuração de
# verdade mora nos arquivos linkados abaixo.
#
# Controlado por editors.helix.enable (declarado em ../editors.nix),
# default true. $EDITOR/$VISUAL não são setados aqui — editors.nix já
# calcula isso dinamicamente pra qualquer editor ligado.
#
# home/configs/helix/themes/onenord.toml é a conversão TOML do tema que
# tínhamos antes em home/modules/helix/theme.nix (já removido do repo).
{
  pkgs,
  lib,
  config,
  ...
}: let
  pkill =
    if pkgs.stdenv.isLinux
    then "${pkgs.procps}/bin/pkill"
    else "/usr/bin/pkill";
  configs = ../../configs/helix;
in {
  config = lib.mkIf config.editors.helix.enable {
    programs.helix = {
      enable = true;
      package = pkgs.helix;
    };

    xdg.configFile = {
      "helix/config.toml" = {
        source = "${configs}/config.toml";
        onChange = ''
          ${pkill} -USR1 -x hx 2>/dev/null || true
        '';
      };

      "helix/languages.toml" = {
        source = "${configs}/languages.toml";
        onChange = ''
          ${pkill} -USR1 -x hx 2>/dev/null || true
        '';
      };

      "helix/themes/onenord.toml".source = "${configs}/themes/onenord.toml";

      "helix/yazi-picker.sh" = {
        source = "${configs}/yazi-picker.sh";
        executable = true;
      };
    };
  };
}
