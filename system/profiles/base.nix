# system/profiles/base.nix
#
# Perfil aplicado a TODOS os hosts NixOS. Junta o que antes eram
# modules/base_system.nix + user_borba.nix + root_pkgs.nix + ssh.nix +
# sops.nix + fonts.nix — cada um cobria um pedaço de config sem
# sobreposição, então a fusão é literal (sem mudança de comportamento).
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
    ../modules/dev
  ];

  # ==================== KERNEL ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== SSH KEY DIR + REGREET DIRS (tmpfiles) ====================
  systemd.tmpfiles.rules = [
    "d ${sshKeysDir} 0700 ${username} users -"
    "d /var/log/regreet 0755 greeter greeter -"
    "d /var/cache/regreet 0755 greeter greeter -"
    "d /var/lib/regreet 0755 greeter greeter -"
  ];

  # ==================== SLEEP POLICY ====================
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    MemorySleepMode = "s2idle";
  };

  # ==================== SECURITY / SESSION ====================
  security.polkit.enable = true;
  security.soteria.enable = true;
  security.pam.services.swaylock = {};
  services.gnome.gnome-keyring.enable = true;

  # ==================== NETWORK ====================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [22];

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

  users.users.greeter.extraGroups = [
    "video"
    "input"
    "render"
  ];

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
  # git → system/modules/dev/base.nix. zsh/eza/zoxide/bat/fzf/delta/direnv
  # → home/modules/shell.nix e cli-and-terminal.nix (HM) — um dono só.
  environment.systemPackages = with pkgs; [
    wget
    curl
    expect # scripts/logitech-k380-bluetooth-linux-fix/*.exp
    age
    sops
    htop
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

  # ==================== FONTS ====================
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      fira-code
      nerd-fonts.fira-mono
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
      nerd-fonts.jetbrains-mono
      libertine
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = ["JetBrainsMono Nerd Font"];
      };
    };
  };
}
