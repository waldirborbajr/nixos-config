# configuration.nix
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  ...
}: let
  # ==================== GLOBAL VARIABLES ====================
  username = "borba"; # Change this if you ever change the main username

  # Common paths used across modules
  dotfilesDir = "/home/${username}/dotfiles";
  dotfileConfigDir = "/home/${username}/.config";

  # Make variables available to all host-specific modules (hosts/*/default.nix)
  common = {
    inherit username dotfilesDir dotfileConfigDir;
  };

  # List of programs whose dotfiles should be symlinked automatically
  # (following the convention: dotfiles/<name>/.config/<name>)
  dotfilePrograms = [
    "tmux"
    "alacritty"
    "i3"
    "i3status"
    "rofi"
    "oh-my-posh"
    # Add more common dotfiles here when needed
  ];

  # Helper function to create symlink rules
  mkDotfileLink = name: "L+ ${dotfileConfigDir}/${name} - - - - ${dotfilesDir}/${name}/.config/${name}";
in {
  # Pass common variables to all modules (including host-specific files)
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix and host-specific configs are imported via flake.nix
  ];

  # ==================== BOOT ====================
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ==================== DOTFILES: Automatic symlinks (no Stow needed) ====================
  # This replaces manual `stow` usage. Symlinks are created on every rebuild.
  systemd.tmpfiles.rules =
    (map mkDotfileLink dotfilePrograms)
    ++ [
      # Special cases for zsh
      "L+ /home/${username}/.zshenv - - - - ${dotfilesDir}/zsh/.zshenv"
      "L+ /home/${username}/.config/zsh - - - - ${dotfilesDir}/zsh/.config/zsh"
    ];

  # ==================== POWER MANAGEMENT ====================
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
    MemorySleepMode = "s2idle";
  };

  # ==================== NETWORKING ====================
  networking.hostName = hostname;
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # ==================== LOCALISATION ====================
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

  # ==================== USER ACCOUNT ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr";
    extraGroups = ["networkmanager" "wheel" "docker"];
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

  # ==================== X11 / i3 ====================
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
    displayManager.lightdm.enable = true;
    services.displayManager.defaultSession = "none+i3";
  };

  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;
  programs.i3lock.enable = true;

  # ==================== SOUND (PipeWire) ====================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ==================== PROGRAMS ====================
  programs = {
    firefox.enable = true;
    fish.enable = true;
  };

  environment.systemPackages =
    (with pkgs; [
      # === Essenciais básicos ===
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
      # === Terminal & Shell ===
      alacritty
      zsh
      # === Nix tools ===
      nixd
      alejandra
      # === Básicos de desktop (i3) ===
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
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;

  # ==================== SERVICES ====================
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [22];

  # ==================== SYSTEM VERSION ====================
  system.stateVersion = "26.05";
}
