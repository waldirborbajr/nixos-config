# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  pkgs-unstable,
  hostname,
  ...
}: {
  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes"; # if you only want to disable hibernation, keep Suspend enabled
    AllowHibernation = "no"; # disable Hibernate
    AllowHybridSleep = "no"; # disable Hybrid Sleep
    AllowSuspendThenHibernate = "no"; # disable suspend-then-hibernate
    MemorySleepMode = "s2idle"; # force s2idle instead of deep sleep
  };

  networking.hostName = hostname; # Define your hostname.
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
  #  hardware.graphics = {
  #    enable = true;
  #    enable32Bit = true;
  #  };

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
      nerd-fonts.iosevka-term # exemplo
      nerd-fonts.caskaydia-cove # Cascadia Code Nerd Font
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Noto Sans" "Noto Sans CJK SC"];
        sansSerif = ["Noto Serif" "Noto Serif CJK SC"];
        monospace = ["FiraCode Nerd Font" "JetBrainsMono Nerd Font"];
      };
    };
  };
  # ----- /Fonts

  # Keyboard layout is configured per-host in hosts/<hostname>/hardware-configuration.nix

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."borba" = {
    isNormalUser = true;
    home = "/home/borba";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
  };

  security.sudo.extraRules = [
    {
      users = ["borba"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  # ----- /X11

  # Enable the X11 windowing system (still needed for i3, even with greetd as login manager).
  services.xserver = {
    enable = true;
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

  # Full GNOME desktop removed — only the pieces i3/Sway actually need to behave
  # well (keyring for secrets/wifi passwords, polkit for privilege prompts).
  services.gnome.gnome-keyring.enable = true;
  security.polkit.enable = true;

  # ----- Login manager: greetd + tuigreet -----
  # Replaces LightDM. greetd is a minimal, session-agnostic login daemon;
  # tuigreet is a TUI greeter that autodiscovers both X11 (xsessions) and
  # Wayland (wayland-sessions) entries — so i3 and Sway both show up as
  # selectable sessions, and it remembers your last choice per user.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = ''
          ${pkgs.tuigreet}/bin/tuigreet \
            --time \
            --remember \
            --remember-user-session \
            --asterisks \
            --sessions /run/current-system/sw/share/wayland-sessions:/run/current-system/sw/share/xsessions
        '';
        user = "greeter";
      };
    };
  };

  # Lets gnome-keyring unlock automatically on greetd login (same as it did via LightDM's PAM).
  security.pam.services.greetd.enableGnomeKeyring = true;

  programs.i3lock.enable = true; # default i3 screen locker
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
    options = "--delete-older-than 3d";
  };
  nix.optimise.automatic = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages =
    (with pkgs; [
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      asciinema
      atuin
      docker
      duf
      fastfetch
      jq
      just
      gh
      git
      stow
      ripgrep
      zsh
      starship
      zellij
      yazi
      eza
      bat
      lazygit
      btop
      htop
      tmux
      helix
      #     discord
      #     brave
      #     chromium
      #     flameshot
      alacritty
      #     emacs
      rofi
      #     yubikey-agent
      #     keepassxc
      #     xss-lock
      pkgs.networkmanagerapplet
      playerctl
      pavucontrol
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
      # # yak shaving
      lxappearance # customize i3 without changing config
      autorandr # auto select a display configuration based on connected devices.
      # # update bios as needed
      #     fwupd
      # # content
      #     kdePackages.kdenlive
      #     obs-studio
      #     mesa # OpenCL for graphics x Davinci on Linux

      # emacs
      emacs
      emacsPackages.pbcopy
      emacsPackages.vterm

      # ===== Helix language servers / formatters =====
      # Go (gopls já está na lista)
      gotools # goimports
      golangci-lint-langserver

      # Rust (rust-analyzer/rustfmt via rustup ficam inconsistentes no PATH;
      # prefira os pacotes nixpkgs abaixo em vez de depender do toolchain do rustup)
      rust-analyzer
      rustfmt

      # Lua
      lua-language-server
      stylua

      # TypeScript / JavaScript
      #nodePackages.typescript-language-server
      #nodePackages.typescript          # dá suporte ao tsserver interno
      #nodePackages.prettier

      # Python
      python3Packages.python-lsp-server # comando: pylsp
      black

      # TOML
      taplo

      # JSON / JSONC
      #nodePackages.vscode-langservers-extracted  # dá vscode-json-language-server

      # YAML
      #nodePackages.yaml-language-server

      # XML
      lemminx

      # Nix
      nixd
      alejandra

      # Dockerfile
      #nodePackages.dockerfile-language-server-nodejs  # comando: docker-langserver

      # Markdown
      marksman

      # Bash
      #nodePackages.bash-language-server
    ])
    ++ (with pkgs-unstable; [
      # ===== Pacotes explicitamente do nixpkgs-unstable =====
      # Software que você quer sempre na versão mais recente disponível,
      # independente da base estável (26.05) do resto do sistema.
      neovim
    ]);

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
  networking.firewall.allowedTCPPorts = [22];
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
