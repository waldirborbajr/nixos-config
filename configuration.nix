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
  sshClientConfigPath = "/etc/ssh/ssh_config.d/50-borba.conf";

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
  # Only the SSH directory creation remains here so sops can write keys
  # before the user session exists. All user configs are managed by HM.
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

  # ==================== SHELL ====================
  # System-level zsh must be enabled whenever a user's login shell is
  # pkgs.zsh, otherwise zsh won't be registered in /etc/shells and the
  # Nix directories won't be added to its PATH (login may become
  # impossible). This is distinct from home-manager's programs.zsh
  # (in home/default.nix), which only manages the user's zsh config
  # files/dotfiles, not the system-level shell registration.
  programs.zsh.enable = true;

  # ==================== USERS ====================
  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "borba jr, w";
    extraGroups = ["networkmanager" "wheel" "podman"];
    shell = pkgs.zsh;
  };

  # Greeter precisa de acesso a DRM / input (obrigatório para cage + regreet)
  users.users.greeter.extraGroups = [ "video" "input" "render" ];

  # ==================== HOME MANAGER (fase 3) ====================
  # User configs live in home/configs/ and are applied via home/default.nix.
  # Host modules only override host-specific fragments (e.g. niri/input.kdl).
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # Pre-existing plain files at HM-managed paths (e.g. from before this
    # migration) get renamed with this suffix instead of blocking
    # activation. Safe to remove once the migration is verified and the
    # .hm-backup files are no longer needed.
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

  # ==================== NIRI (Wayland) ====================
  # NOTA: migrado de i3/X11 para niri (Wayland scrollable-tiling compositor)
  # + noctalia-shell (shell baseado em Quickshell).
  # O módulo `programs.niri` registra a sessão niri automaticamente em
  # /run/current-system/sw/share/wayland-sessions.
  programs.niri.enable = true;

  # ==================== GREETD + REGREET (Catppuccin Mocha/Mauve) ====================
  # greetd é o daemon de login; regreet é o greeter gráfico GTK.
  # Em VMs (virtio-gpu / VMware) o cage costuma precisar de GSK_RENDERER=cairo
  # e WLR_NO_HARDWARE_CURSORS=1, senão o greeter sai imediatamente.
  services.greetd.enable = true;

programs.regreet = {
  enable = true;

  theme = {
    name = "Catppuccin-Mocha-Standard-Mauve-Dark";
    package = pkgs.catppuccin-gtk.override {
      accents = [ "mauve" ];
      size = "standard";
      tweaks = [ ];
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

  cageArgs = [ "-s" ];

  settings = {
    GTK = {
      application_prefer_dark_theme = true;
      theme_name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      icon_theme_name = "Papirus-Dark";
      cursor_theme_name = "Catppuccin-Mocha-Mauve-Cursors";
      font_name = "JetBrainsMono Nerd Font 12";
    };

    # Wallpaper da tela de login (tem que ficar aqui dentro de settings)
    background = {
      path = "${./home/configs/wallpapers/login.jpg}";
      fit = "Fill";   # Cover | Contain | Fill | ScaleDown
    };
  };
};

  # Força o comando com variáveis estáveis para VM (virtio-gpu / VMware Fusion)
  services.greetd.settings.default_session.command = lib.mkForce ''
    ${pkgs.dbus}/bin/dbus-run-session \
    env GSK_RENDERER=cairo WLR_NO_HARDWARE_CURSORS=1 WLR_RENDERER=pixman \
    ${lib.getExe pkgs.cage} -s -- ${lib.getExe pkgs.greetd.regreet}
  '';

  services.displayManager.defaultSession = "niri";
  security.polkit.enable = true;

  # Polkit auth agent para o niri (standalone WM, sem DE que já forneça um).
  # Substitui o antigo spawn-at-startup "/usr/lib/soteria-polkit/soteria" do
  # startup.kdl/misc.kdl — aquele caminho é FHS (Arch/Ubuntu) e não existe no
  # NixOS. Este módulo já cuida de instalar o pacote e rodar como serviço de
  # usuário; remova a linha spawn-at-startup correspondente dos configs do niri.
  security.soteria.enable = true;

  # waybar tem o módulo "power-profiles-daemon" no config.jsonc; sem o serviço
  # dbus rodando, esse módulo simplesmente fica quebrado/vazio.
  services.power-profiles-daemon.enable = true;

  # gsettings (usado no misc.kdl pra setar o tema do cursor) precisa do dconf
  # rodando; sem isso o comando falha silenciosamente.
  programs.dconf.enable = true;

  # lock screen usado pelo bind padrão do noctalia (Mod+L -> lockScreen lock)
  # `programs.swaylock.enable` NÃO existe no NixOS puro (é opção do
  # home-manager) — aqui é só o pacote + PAM manual, senão o unlock falha
  # com "pam_authenticate failed: invalid credentials".
  security.pam.services.swaylock = {};

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
      gh # github-cli
      gh-dash
      tmux
      bat
      ripgrep
      eza
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
      wl-clipboard # substitui xclip no Wayland
      xwayland-satellite # compat pra apps que só falam X11 dentro do niri
      # inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

      # ---- niri + waybar (compartilhado por todos os hosts) ----
      waybar # a bar em si; sem isso config.jsonc/style.css do HM não têm o que rodar
      fuzzel # launcher (Mod+D) e power-menu.sh do waybar (dmenu mode)
      swaybg # wallpaper, chamado no startup.kdl
      wlr-which-key # menu invocado no bind Mod+Shift+E (binds.kdl)
      orca # leitor de tela, bind Super+Alt+S (binds.kdl)
      networkmanagerapplet # fornece o nm-applet chamado no misc.kdl
      nextcloud-client # fornece o binário "nextcloud" chamado no misc.kdl
      capitaine-cursors # tema de cursor setado via gsettings no misc.kdl
      qt6Packages.qt6ct # QT_QPA_PLATFORMTHEME=qt6ct está setado no misc.kdl
    ])
    ++ (with pkgs-unstable; [
      neovim
      helix
      # noctalia-shell
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
