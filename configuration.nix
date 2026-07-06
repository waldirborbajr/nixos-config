{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  lib,
  ...
}: let
  username = "borba";

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
      "L+ /home/${username}/.zshenv - - - - ${dotfilesDir}/zsh/.zshenv"
      "L+ /home/${username}/.config/zsh - - - - ${dotfilesDir}/zsh/.config/zsh"
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

  # ==================== BLUETOOTH ====================
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

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
    extraGroups = ["networkmanager" "wheel"];
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

  # ==================== X11 + i3 + LIGHTDM ====================
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

    displayManager.lightdm = {
      enable = true;

      greeters.gtk = {
        enable = true;

        theme = {
          package = pkgs.catppuccin-gtk.override {
            accents = ["mauve"];
            size = "standard";
            variant = "mocha";
          };
          name = "catppuccin-mocha-mauve-standard";
        };

        iconTheme = {
          package = pkgs.papirus-icon-theme;
          name = "Papirus-Dark";
        };

        cursorTheme = {
          package = pkgs.catppuccin-cursors.mochaDark;
          name = "catppuccin-mocha-dark-cursors";
        };

        extraConfig = ''
          font-name = FiraCode Nerd Font 11
          xft-antialias = true
          xft-hintstyle = hintslight
          indicators = ~host;~spacer;~clock;~spacer;~session;~language;~a11y;~power
        '';
      };
    };
  };

  services.displayManager.defaultSession = "none+i3";

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.i3lock.enable = true;

  # ==================== AUDIO ====================
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

  programs = {
    firefox.enable = lib.mkDefault true;
    fish.enable = true;
  };

  # ==================== PACKAGES ====================
  environment.systemPackages =
    (with pkgs; [
      wget
      curl
      git
      helix
      tmux
      bat
      ripgrep
      eza
      btop
      htop
      fastfetch
      oh-my-posh
      alacritty
      zsh
      nixd
      alejandra
      rofi
      feh
      picom
      xclip
      lxappearance
    ])
    ++ (with pkgs-unstable; [
      neovim
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
    defaultSopsFile = ./secrets/${hostname}.yaml;

    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    validateSopsFiles = false;
  };

  sops.secrets."ssh_host_ed25519_key" = {
    path = "/etc/ssh/ssh_host_ed25519_key";
    owner = "root";
    mode = "0600";
  };

# ==================== ZERO-TOUCH SSH HOST KEY BOOTSTRAP ====================

systemd.services.ssh-hostkey-bootstrap = {
  description = "Bootstrap SSH host key into SOPS on first boot";

  wantedBy = ["multi-user.target"];
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
