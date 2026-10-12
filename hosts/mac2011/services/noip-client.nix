# hosts/mac2011/services/noip-client.nix
#
# No-IP dynamic DNS (cliente Rust): github.com/waldirborbajr/NoIPClient
# Só mac2011. Credenciais (NOIP_* e TELEGRAM_*) vêm do sops-nix,
# gravadas em /run/secrets/noip-env — nunca em arquivo versionado.
{
  config,
  pkgs,
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "waldirborbajr";
    repo = "NoIPClient";
    rev = "358397518583aef77abf26217a7aa4fc0f320100";
    hash = "sha256-v6qAIA56SIQjmWJeVocLs82saYhk4HoI42Y6wZSXngY=";
  };
  noipClient = pkgs.rustPlatform.buildRustPackage {
    pname = "noip-client";
    version = "0.1.0";
    inherit src;
    cargoLock.lockFile = "${src}/Cargo.lock";
    # openssl-sys (via reqwest/native-tls) precisa de pkg-config + openssl
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.openssl];
  };
in {
  # Segredo: chave `noip-env` dentro de hosts/mac2011/secrets/mac2011.yaml,
  # conteúdo no formato .env (NOIP_HOSTNAME=..., NOIP_PASSWORD=..., etc).
  sops.secrets."noip-env" = {
    sopsFile = ../secrets/mac2011.yaml;
    key = "noip-env";
    mode = "0400"; # só root lê; systemd lê o EnvironmentFile antes de trocar de usuário
  };

  systemd.services.noip-client = {
    description = "No-IP dynamic update check";
    after = ["network-online.target"];
    wants = ["network-online.target"];
    environment = {
      # Estado persistente em /var/lib/noip-client (StateDirectory) em vez
      # do default "last_ip.txt" no working directory.
      STATE_FILE = "/var/lib/noip-client/last_ip.txt";
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${noipClient}/bin/noip-client";
      StateDirectory = "noip-client";
      EnvironmentFile = config.sops.secrets."noip-env".path;
      DynamicUser = true;
    };
  };

  systemd.timers.noip-client = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "3h"; # README sugere 5min = ~288 msgs/dia no Telegram
      Persistent = true;
    };
  };
}
