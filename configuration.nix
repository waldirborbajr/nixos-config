{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  hostname,
  inputs,
  ...
}: let
  username = "borba";
  sshKeysDir = "/home/${username}/.ssh";

  # Shared values for host modules (username mainly).
  # Dotfile contents now live inside the flake under home/configs/ (fase 3).
  common = {
    inherit username;
  };
in {
  _module.args.common = common;

  imports = [
    # hardware-configuration.nix is imported per-host via flake.nix
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

  # ==================== SHELL ====================
  programs.zsh.enable = true;

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel" "podman" "dialout"]; # dialout: cabo serial do CHIRP
    shell = pkgs.zsh;
  };

  users.users.greeter.extraGroups = ["video" "input" "render"];

  # ==================== HOME MANAGER ====================
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-backup";

    extraSpecialArgs = {
      inherit inputs hostname pkgs-unstable;
    };

    users.${username} = import ./home/default.nix;
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

  # ==================== NIRI ====================
  programs.niri.enable = true;

  # ==================== GREETD + REGREET ====================
  services.greetd.enable = true;

  programs.regreet = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = ["mauve"];
        size = "standard";
        tweaks = [];
        variant = "mocha";
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.symlinkJoin {
        name = "papirus-catppuccin-mauve";
        paths = [
          pkgs.papirus-icon-theme
          (pkgs.catppuccin-papirus-folders.override {
            accent = "mauve";
            flavor = "mocha";
          })
        ];
      };
    };

    cursorTheme = {
      name = "Catppuccin-Mocha-Mauve-Cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

    cageArgs = ["-s"];

    settings = {
      GTK = {
        application_prefer_dark_theme = true;
        theme_name = "Catppuccin-Mocha-Standard-Mauve-Dark";
        icon_theme_name = "Papirus-Dark";
        cursor_theme_name = "Catppuccin-Mocha-Mauve-Cursors";
        font_name = "JetBrainsMono Nerd Font 12";
      };

      background = {
        path = "${./home/configs/wallpapers/login.jpg}";
        fit = "Fill";
      };
    };
  };

  services.displayManager.defaultSession = "niri";

  services.power-profiles-daemon.enable = true;

  programs.dconf.enable = true;

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

  # ==================== XDG DESKTOP PORTAL ====================
  # niri não tem DE por trás dele, então precisa de um backend de portal
  # explícito. gnome = screen share/gravação (Brave, Discord, OBS via
  # PipeWire); gtk = file chooser de apps sandboxed/Electron.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [xdg-desktop-portal-gnome xdg-desktop-portal-gtk];
    config.common.default = ["gnome"];
  };

  # ==================== NIX-LD ====================
  # Permite rodar binários dinâmicos genéricos de Linux (ex.: RadioManager
  # de CPS de rádio, instaladores .run, etc.) que esperam um ld-linux.so e
  # libs em /lib, coisa que o NixOS não tem fora da Nix store.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib
      libusb1 # acesso USB direto (CPS de rádio, programadores)
      udev
      icu # runtime .NET (RadioManager e outros CPS baseados em .NET)
      fontconfig # SkiaSharp (UI gráfica do RadioManager) precisa pra achar fontes
      freetype
      harfbuzz
    ];
  };

  # ==================== BLUETOOTH ====================
  # Voltado ao estado mínimo original. Testamos disable_ertm=1 (quebrou
  # setsockopt do bluetoothd), Policy.AutoEnable/ReconnectAttempts/
  # JustWorksRepairing (suspeito de brigar com pareamento manual em
  # background) e regra de udev de autosuspend — nenhum resolveu, e o
  # usuário confirmou que o MESMO hardware pareia sem problema no Fedora
  # com bluez "de fábrica". Ou seja: quanto menos customização aqui,
  # mais perto do baseline que sabemos que funciona.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
    };
  };

  services.blueman.enable = true;

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

  # ==================== PACKAGES ====================
  environment.systemPackages =
    (with pkgs; [
      wget
      atuin
      curl
      expect
      git
      gh
      gh-dash
      delta
      tmux
      bat
      ripgrep
      eza
      zoxide

      kdlfmt
      # Compactação / descompactação
      unzip
      zip
      p7zip # 7z (também lida com vários outros formatos)
      xarchiver # GUI leve (GTK) para abrir/extrair zip, 7z, tar, rar, etc.
      # combina bem com um setup minimalista tipo niri/waybar
      # (não puxa dependências pesadas do GNOME como o file-roller)
      btop
      htop
      fastfetch
      oh-my-posh
      alacritty
      wezterm
      zsh
      nixd
      alejandra
      age
      sops
      swaylock
      swayidle
      grim
      slurp
      swappy
      cliphist
      wl-clipboard
      xwayland-satellite
      waybar
      fuzzel
      swaybg
      wlr-which-key
      orca
      networkmanagerapplet
      nextcloud-client
      capitaine-cursors
      qt6Packages.qt6ct
      seahorse
    ])
    ++ (with pkgs-unstable; [
      neovim
      helix
    ])
    ++ [
      (pkgs.writeShellScriptBin "noctalia" ''
        exec ${pkgs-unstable.noctalia-shell}/bin/noctalia-shell "$@"
      '')
      (pkgs.writeShellScriptBin "qs" ''
        exec ${pkgs-unstable.noctalia-shell}/bin/noctalia-shell "$@"
      '')
    ];

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

  # SSH client configuration is generated by NixOS.
  # No manual /etc/ssh/ssh_config.d/50-borba.conf is needed.
  programs.ssh = {
    extraConfig = ''
      Host 192.168.* *.infra
        HostName %h
        User ${username}
        IdentityFile ${sshKeysDir}/id_ed25519_infra
        IdentitiesOnly yes

      Host github.com gitlab.com
        User git
        IdentityFile ${sshKeysDir}/id_ed25519_github
        IdentitiesOnly yes

      Host gitea.com
        User git
        IdentityFile ${sshKeysDir}/id_ed25519_github
        IdentitiesOnly yes

      Host codeberg.org
        User git
        IdentityFile ${sshKeysDir}/id_ed25519_github
        IdentitiesOnly yes

      Host codefloe.com
        User git
        IdentityFile ${sshKeysDir}/id_ed25519_github
        IdentitiesOnly yes

      Host forgejo.local
        HostName forgejo.local
        User git
        IdentityFile ${sshKeysDir}/id_ed25519_github
        IdentitiesOnly yes
    '';
  };

  # ==================== SOPS ====================
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

  # ==================== STATE VERSION ====================
  system.stateVersion = "26.05";
}
