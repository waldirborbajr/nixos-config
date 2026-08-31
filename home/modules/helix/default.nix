# home/modules/helix/default.nix
#
# Helix configurado a partir dos arquivos TOML crus em home/configs/helix/
# (linkados via xdg.configFile), não mais gerado a partir de atributos Nix.
# Esse é o modelo anterior à experiência de representar tudo em Nix attrset
# (ver git log) — restaurado a pedido. programs.helix aqui só instala o
# pacote/binário; toda configuração de verdade mora nos arquivos linkados
# abaixo, então ficam editáveis/diffáveis como Helix config puro, fora do
# formato de atributos do Nix.
#
# home/configs/helix/themes/onenord.toml é a conversão TOML do tema que
# tínhamos em home/modules/helix/theme.nix (agora obsoleto/sem uso — pode
# ser removido do repo).
{pkgs, ...}: let
  pkill =
    if pkgs.stdenv.isLinux
    then "${pkgs.procps}/bin/pkill"
    else "/usr/bin/pkill";
  configs = ../../configs/helix;
in {
  home.sessionVariables.EDITOR = "hx";
  home.sessionVariables.COLORTERM = "truecolor";

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
}
