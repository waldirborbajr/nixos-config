# hosts/mac2011/services/flatpak.nix
#
# Flatpak exclusivo do mac2011 (Linux x86_64). Não existe no macOS, e o
# nixpkgs não tem mais o pacote brave, então o Brave entra daqui via Flathub.
#
# O NixOS não declara apps Flatpak; por isso o serviço abaixo adiciona o
# remote flathub e instala os apps listados no primeiro boot com rede.
# Já instalado → não faz nada. Atualizações: `flatpak update` (alias no zsh).
#
# AVISO: com.anydesk.Anydesk é um wrapper da comunidade (Flathub), não
# oficial da AnyDesk Software GmbH.
{pkgs, ...}: let
  flatpakApps = [
    "com.brave.Browser"
#    "com.anydesk.Anydesk"
  ];
in {
  services.flatpak.enable = true;

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
      for app in ${builtins.concatStringsSep " " flatpakApps}; do
        if ! flatpak info --system "$app" >/dev/null 2>&1; then
          flatpak install --system -y --noninteractive flathub "$app"
        fi
      done
    '';
  };
}
