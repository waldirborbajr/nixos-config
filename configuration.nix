# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";              # if you only want to disable hibernation, keep Suspend enabled
    AllowHibernation = "no";           # disable Hibernate
    AllowHybridSleep = "no";           # disable Hybrid Sleep
    AllowSuspendThenHibernate = "no";  # disable suspend-then-hibernate
  };

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Bluetooth backend — required for blueman (tray/GUI) to find any adapter.
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # GPU acceleration (video playback, terminal rendering, compositing, etc.)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
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

  # ----- Fonts (merged into a single block)
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji

      dejavu_fonts

      jetbrains-mono

      nerd-fonts.fira-code
      nerd-fonts.fira-mono
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Sans" "Noto Sans CJK SC"];
        sansSerif = ["Noto Serif" "Noto Serif CJK SC"];
        monospace = ["JetBrainsMono Nerd Font" "Fira Code"];
      };
    };
  };
  # ----- /Fonts

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "mac";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."borba" = {
    isNormalUser = true;
    home = "/home/borba";
    description = "borba w jr";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  security.sudo.extraRules = [
      {
        users = [ "borba" ];
        commands = [
          { command = "ALL"; options = [ "NOPASSWD" ]; }
        ];
      }
    ];

# ----- /X11

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    displayManager = {
      lightdm = {
        enable = true;
        greeters.gtk.enable = true;
      };
    };
   desktopManager = {
      xterm.enable = false;
    };
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

  # Full GNOME desktop removed — only the pieces i3 actually needs to behave
  # well (keyring for secrets/wifi passwords, polkit for privilege prompts).
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  services.displayManager.defaultSession = "none+i3";

programs.i3lock.enable = true; # default i3 screen locker

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = "borba";
# ----- /X11

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.permittedInsecurePackages = [
#    "broadcom-sta-6.30.223.271-57-6.12.41"
#  ];

  # Install firefox.
  programs = {
    firefox.enable = true;
    fish.enable = true;
  };

  # Keep the Nix store from growing unbounded across frequent rebuilds.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    neovim
    stow
    ripgrep
    zsh
    yazi
    eza
    bat
    lazygit
    btop
    htop
    tmux
#     discord
#     brave
#     chromium
#     flameshot
     alacritty
#     emacs
#     rofi
#     yubikey-agent
#     keepassxc
#     xss-lock
#     pkgs.networkmanagerapplet
#     playerctl
#     pavucontrol
#     lolcat
     xkill
    xclip
    coreutils
#     element-web
#     zed-editor
#     bluez
# # emacs deps
# # make packages available to emacsclient (see nixos wiki's emacs docs)
#     emacsPackages.pbcopy
#     emacsPackages.vterm
#     libvterm
#     libtool

     gcc
     glibc
     libcxx
     gdb
     cmake
     gnumake
     libgcc

#     pam_u2f
#     ispell
 # language servers
     gopls
#     haskell-language-server
 # rust stuff
     jetbrains.rust-rover
     rustup
# # languages
     go
# # yak shaving
#     greetd
#     tuigreet
#     lxappearance # customize i3 without changing config
#     lightdm # display manager for login
#     autorandr # auto select a display configuration based on connected devices.
# # update bios as needed
#     fwupd
# # content
#     kdePackages.kdenlive
#     obs-studio
#     mesa # OpenCL for graphics x Davinci on Linux
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?

}
