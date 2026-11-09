# system/modules/flatpak.nix
#
# Flatpak global: disponível para qualquer host NixOS, ligado por host.
# Default OFF. Ative no configuration.nix do host:
#
#   flatpak.enable = true;
#   flatpak.apps = [ "com.brave.Browser" ];
#
# Na primeira ativação com rede, o serviço `flatpak-apps` adiciona o remote
# flathub e instala os apps listados. Já instalado → não faz nada.
# Atualizações: `flatpak update` (alias no zsh).
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.flatpak;
in {
  options.flatpak = {
    enable = lib.mkEnableOption "Flatpak + Flathub com instalação declarativa de apps";

    apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["com.brave.Browser"];
      description = "IDs de app do Flathub instalados no sistema.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.flatpak.enable = true;

    # Os atalhos (.desktop) dos apps Flatpak ficam em
    # /var/lib/flatpak/exports/share. Sem isso no XDG_DATA_DIRS, o rofi
    # (drun) e outros launchers não os enxergam.
    environment.profiles = ["/var/lib/flatpak/exports"];

    systemd.services.flatpak-apps = {
      description = "Install Flatpak apps from Flathub";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target"];
      path = [pkgs.flatpak];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        flatpak remote-add --system --if-not-exists flathub \
          https://dl.flathub.org/repo/flathub.flatpakrepo
        for app in ${lib.concatStringsSep " " cfg.apps}; do
          if ! flatpak info --system "$app" >/dev/null 2>&1; then
            flatpak install --system -y --noninteractive flathub "$app"
          fi
        done
      '';
    };
  };
}
