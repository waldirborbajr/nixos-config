{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  ...
}: let
  username = "borba";
  sshKeysDir = "/home/${username}/.ssh";
  sshClientConfigPath = "/etc/ssh/ssh_config.d/50-borba.conf";

  dotfilesDir = "/home/${username}/dotfiles";
  dotfileConfigDir = "/home/${username}/.config";

  common = {
    inherit username dotfilesDir dotfileConfigDir;
  };

  dotfilePrograms = [
    "tmux"
    "alacritty"
    "i3"
    "i3status"
    "rofi"
    "oh-my-posh"
    "helix"
    "git"
    "zsh"
    # add more as needed
  ];

  mkDotfileLink = name:
    "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix
  ];

  # ==================== KERNEL ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== AUTOMATIC DOTFILES ====================
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      "d ${sshKeysDir} 0700 ${username} users -"
      "L+ /home/${username}/.zshenv - - - - ${dotfilesDir}/zsh/.zshenv"
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
        monospace = ["FiraCode Nerd Font" "JetBrainsMono Nerd Font"];
      };
    };
  };

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel" "podman"];
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

  # ==================== X11 + i3 + LY ====================
  # NOTA (branch de teste): LightDM foi substituído por ly aqui, buscando um
  # display manager mais leve (sem stack GTK). Pontos confirmados antes de
  # aplicar, documentados para referência futura:
  #   - services.displayManager.ly.settings tem um bug conhecido reportado
  #     no NixOS Discourse onde o merge de config pode fazer a lista de
  #     sessões (ex: i3) sumir da tela do ly. Teste via
  #     `./nixos-manager.sh dry` antes de aplicar de verdade, e mantenha uma
  #     sessão SSH separada aberta no primeiro `switch` real.
  #   - bg/fg no config.ini só afetam a caixa de diálogo e a barra superior;
  #     o fundo de tela cheio do ly é sempre preto, não é configurável por
  #     aqui (exigiria sobrescrever o unit systemd do ly com sequências ANSI).
  #   - Cores usam IDs inteiros (0-8), não hex 0xRRGGBB — hex 24-bit só é
  #     suportado em builds mais recentes do ly; não confirmado para a
  #     revisão de nixpkgs que este flake resolve. Ajustar para hex somente
  #     após checar `ly --version` e o /etc/ly/config.ini real gerado.
  #   - Não existe módulo catppuccin/nix oficial para o ly (só para sddm),
  #     então este tema é uma aproximação manual, não um pacote de tema.
  services.xserver = {
    enable = true;

    desktopManager.xterm.enable = false;

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        polybar
        i3status
        i3blocks
        rofi
      ];
    };
  };

services.displayManager.ly = {
  enable = true;
  settings = {
    animation = "matrix";
    bigclock = true;

    bg = "0x001e1e2e";          # Base
    fg = "0x00cba6f7";          # Mauve (mesmo accent do resto do seu setup)
    border_fg = "0x00cba6f7";   # Mauve
    error_fg = "0x00f38ba8";    # Red (Catppuccin, não vermelho puro)
    clock_color = "0x00cba6f7"; # Mauve

    term_reset_cmd = "/usr/bin/tput reset; echo -en \"\\e]P01e1e2e\"; echo -en \"\\e]P7cdd6f4\\ec\"; clear";

    blank_password = true;
    hide_borders = false;
    default_input = "login";
    load = true;
    save = true;
  };
};

  services.displayManager.defaultSession = "none+i3";
  security.polkit.enable = true;
  programs.i3lock.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==================== PROGRAMS ====================
  nixpkgs.config.allowUnfree = true;

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  environment.shellAliases = {
    vi = "hx";
    vim = "hx";
    nvim = "hx";
  };

  # SSH client host-specific identity selection is handled by the activation
  # script below, which writes /etc/ssh/ssh_config.d/50-borba.conf for this
  # NixOS release.

  # ==================== PACKAGES ====================
  environment.systemPackages =
    (with pkgs; [
      wget
      curl
      git
      # tuicr
      tmux
      # herdr
      bat
      ripgrep
      eza
      btop
      htop
      neohtop-cli
      fastfetch
      oh-my-posh
      alacritty
      zsh
      nixd
      alejandra
      age
      sops
      rofi
      feh
      picom
      xclip
    ])
    ++ (with pkgs-unstable; [
      neovim
      helix
    ]);

  # ==================== NIX ====================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  nix.optimise.automatic = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

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

  sops = {
    defaultSopsFile = ./hosts/${hostname}/secrets/${hostname}.yaml;

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

  system.activationScripts.setupBorbaSshKeys = ''
    install -d -o ${username} -g users -m 700 ${sshKeysDir}
    install -d -o root -g root -m 755 /etc/ssh/ssh_config.d

    cat > ${sshClientConfigPath} <<EOF
    Host 192.168.* *.infra
      HostName %h
      User ${username}
      IdentityFile ${sshKeysDir}/id_ed25519_infra
      IdentitiesOnly yes

    Host github.com gitlab.com
      User git
      IdentityFile ${sshKeysDir}/id_ed25519_github
      IdentitiesOnly yes

    Host gitea.com gitea.com
      User git
      IdentityFile ${sshKeysDir}/id_ed25519_github
      IdentitiesOnly yes

    Host codeberg.org codeberg.org
      User git
      IdentityFile ${sshKeysDir}/id_ed25519_github
      IdentitiesOnly yes

    Host codefloe.com codefloe.com
      User git
      IdentityFile ${sshKeysDir}/id_ed25519_github
      IdentitiesOnly yes

    Host forgejo.local
      HostName forgejo.local
      User git
      IdentityFile ${sshKeysDir}/id_ed25519_github
      IdentitiesOnly yes
    EOF

    chown ${username}:users ${sshKeysDir}
    chmod 700 ${sshKeysDir}
    chown root:root ${sshClientConfigPath}
    chmod 644 ${sshClientConfigPath}
  '';

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

      # se já existe secret, não faz nada
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

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
