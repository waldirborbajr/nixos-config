# hosts/mac2011/services/flatpak.nix
#
# Flatpak exclusivo do mac2011 (Linux x86_64). Não existe no macOS, e o
# nixpkgs não tem mais o pacote brave, então o Brave entra daqui via Flathub.
#
# O NixOS não declara apps Flatpak; por isso o serviço abaixo adiciona o
# remote flathub e instala com.brave.Browser no primeiro boot com rede.
# Já instalado → não faz nada. Atualizações: `flatpak update` (alias no zsh).
{pkgs, ...}: let
  braveApp = "com.brave.Browser";
in {
  services.flatpak.enable = true;

  systemd.services.flatpak-brave = {
    description = "Install Brave (Flatpak, Flathub)";
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
      if ! flatpak info --system ${braveApp} >/dev/null 2>&1; then
        flatpak install --system -y --noninteractive flathub ${braveApp}
      fi
    '';
  };
}
