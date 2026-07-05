# configuration.nix
{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
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
    # adicione outros conforme for precisando
  ];

  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== DOTFILES AUTOMÁTICOS ====================
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      "L+ /home/${username}/.zshenv - - - - ${dotfilesDir}/zsh/.zshenv"
      "L+ /home/${username}/.config/zsh - - - - ${dotfilesDir}/zsh/.config/zsh"
    ];

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    MemorySleepMode = "s2idle";
  };

  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

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

  # ==================== X11 + i3 + LightDM ====================
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

  # Corrected option (was in the wrong place)
  services.displayManager.defaultSession = "none+i3";

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.i3lock.enable = true;

  # ==================== SOUND ====================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==================== PROGRAMS & PACKAGES ====================
  nixpkgs.config.allowUnfree = true;

  programs = {
    firefox.enable = true;
    fish.enable = true;
  };

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

  # ==================== NIX SETTINGS ====================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  system.stateVersion = "26.05";
}
