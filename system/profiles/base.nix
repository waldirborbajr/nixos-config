# system/profiles/base.nix
#
# Perfil aplicado a TODOS os hosts NixOS, inclusive um futuro nó sem tela
# gráfica — nada aqui pode depender de sessão gráfica (greetd/regreet,
# polkit agent gráfico, fontes, etc.); isso tudo mora em
# system/profiles/desktop.nix, igual à separação do ulyssecrn/nixos-config
# (base.nix dele também não toca em nada gráfico).
# O wiring `home-manager.users.borba` NÃO mora aqui — vive no flake.nix
# (mkHost), um lugar só pra toda a frota.
{
  pkgs,
  hostname,
  ...
}: let
  username = "borba";
  sshKeysDir = "/home/${username}/.ssh";
in {
  imports = [
    ../modules/dev.nix
    ../modules/ssh-trust.nix
  ];

  # ==================== KERNEL ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== SSH KEY DIR (tmpfiles) ====================
  systemd.tmpfiles.rules = [
    "d ${sshKeysDir} 0700 ${username} users -"
  ];

  # ==================== SLEEP POLICY ====================
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    MemorySleepMode = "s2idle";
  };

  # ==================== NETWORK ====================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  # Tailscale — LAN local é 192.168.0.0/24; o tailnet usa a faixa própria
  # dele (100.64.0.0/10), sem sobreposição. Nada de rota de sub-rede
  # anunciada por enquanto — só a malha entre os hosts que a tiverem
  # instalada.
  services.tailscale.enable = true;
  # As duas linhas abaixo evitam problema de DNS com o tailscale — mesmo
  # padrão do ulyssecrn: https://github.com/tailscale/tailscale/issues/4254
  services.resolved.enable = true;
  networking.useNetworkd = false;

  # ==================== TIME / LOCALE ====================
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # ==================== SHELL ====================
  programs.zsh.enable = true;

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "dialout"
    ]; # dialout: cabo serial do CHIRP
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";
  };

  security.sudo.extraRules = [
    {
      users = [username];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # ==================== NIX ====================
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # ==================== PACKAGES (núcleo mínimo, fora do painel de features) ====================
  # git → system/modules/dev.nix. zsh/eza/zoxide/bat/fzf/delta/direnv
  # → home/modules/shell.nix e cli-and-terminal.nix (HM) — um dono só.
  environment.systemPackages = with pkgs; [
    wget
    curl
    expect # scripts/logitech-k380-bluetooth-linux-fix/*.exp
    age
    sops
    htop
    smartmontools
    net-tools
    superfile

    # Core — vieram de system/modules/dev.nix (faziam parte do bloco
    # "BASE sempre presente" de lá, mas não são ferramenta de dev, são
    # básico de sistema; todo host deve ter independente de
    # development.languages.*).
    git
    ripgrep
    tree
  ];

  # ==================== SSH ====================
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  # Client identities separadas por finalidade:
  #   infra  -> SSH entre ambientes gerenciados
  #   github -> GitHub (chave existente)
  #   gitlab -> GitLab (preparado pra uma chave dedicada)
  #   forgejo -> Forgejo (preparado pra uma chave dedicada)
  programs.ssh = {
    extraConfig = ''
      Host 192.168.* *.infra
        User ${username}
        IdentityFile /home/${username}/.ssh/id_ed25519_infra
        IdentitiesOnly yes

      Host github.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_github
        IdentitiesOnly yes

      Host gitlab.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_gitlab
        IdentitiesOnly yes

      Host forgejo.local
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_forgejo
        IdentitiesOnly yes

      Host gitea.com codeberg.org codefloe.com
        User git
        IdentityFile /home/${username}/.ssh/id_ed25519_github
        IdentitiesOnly yes
    '';
  };

  # ==================== SOPS ====================
  sops = {
    defaultSopsFile = ../../hosts/${hostname}/secrets/${hostname}.yaml;
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
    validateSopsFiles = false;
  };

  sops.secrets."ssh_host_ed25519_key" = {
    path = "/etc/ssh/ssh_host_ed25519_key";
    owner = "root";
    mode = "0600";
  };

  sops.secrets."borba_ssh_infra_private_key" = {
    path = "${sshKeysDir}/id_ed25519_infra";
    owner = username;
    group = "users";
    mode = "0600";
  };

  sops.secrets."borba_ssh_infra_public_key" = {
    path = "${sshKeysDir}/id_ed25519_infra.pub";
    owner = username;
    group = "users";
    mode = "0644";
  };

  sops.secrets."borba_ssh_github_private_key" = {
    path = "${sshKeysDir}/id_ed25519_github";
    owner = username;
    group = "users";
    mode = "0600";
  };

  sops.secrets."borba_ssh_github_public_key" = {
    path = "${sshKeysDir}/id_ed25519_github.pub";
    owner = username;
    group = "users";
    mode = "0644";
  };

  # Identidades dedicadas de GitLab/Forgejo ainda não declaradas — ver
  # nota original em system/modules (histórico) antes de reativar.

  # ==================== ZERO-TOUCH SSH HOST KEY BOOTSTRAP ====================
  systemd.services.ssh-hostkey-bootstrap = {
    description = "Bootstrap SSH host key into SOPS on first boot";

    wantedBy = ["multi-user.target"];
    wants = ["sshd.service"];
    before = ["sshd.service"];
    after = ["network.target"];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };

    script = ''
      set -euo pipefail

      KEY="/etc/ssh/ssh_host_ed25519_key"

      if [ -f "$KEY" ]; then
        exit 0
      fi

      mkdir -p /etc/ssh

      echo "[bootstrap] generating ssh host key..."

      ssh-keygen -t ed25519 -f "$KEY" -N ""

      echo "[bootstrap] WARNING: key generated locally."

      echo "[bootstrap] you should now encrypt it with sops:"
      echo "  sops hosts/${hostname}/secrets/${hostname}.yaml"
    '';
  };
}
