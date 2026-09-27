# home/modules/desktop.nix
#
# Notificações (mako), keyring de sessão e a parte do compositor
# niri/waybar/wlr-which-key comum a TODOS os hosts NixOS (incluindo o
# Dell — é o núcleo da sessão gráfica, não um extra opcional). Extras
# só pra família Mac (não-Dell) ficam em home/profiles/x86/desktop.nix.
# Overrides por host (input/outputs do niri) ficam em
# hosts/<host>/home/home.nix.
{
  pkgs,
  pkgs-unstable,
  ...
}: let
  configs = ../configs;
in {
  # ==================== GTK / ÍCONES (sessão real, não o greeter) ====================
  # O Papirus-Dark em modules/desktop_niri.nix só é usado pelo regreet
  # (tela de login) — a sessão niri em si não tinha NENHUM tema de ícones
  # apontado, então apps GTK (Nemo, etc.) e o Vicinae caíam no ícone
  # genérico "?" por falta de XDG icon theme. Mesma combinação
  # Papirus + overlay Catppuccin usada no regreet, só que instalada/mapeada
  # aqui pra sessão do usuário via home-manager.
  gtk = {
    enable = true;
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
  };

  services.mako = {
    enable = true;
    settings = {
      # opcional — estilo Catppuccin Mocha
      background-color = "#1e1e2e";
      text-color = "#cdd6f4";
      border-color = "#cba6f7";
      border-size = 2;
      border-radius = 8;
      padding = "10";
      default-timeout = 5000;
      font = "JetBrainsMono Nerd Font 11";
    };
  };

  services.gnome-keyring = {
    enable = true;
    components = [
      "pkcs11"
      "secrets"
      "ssh"
    ];
  };

  # Se quiser usar o keyring como SSH agent:
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";

  # ==================== SESSÃO NIRI/WAYBAR (binários) ====================
  # Migrado de modules/root_pkgs.nix — a config de niri/waybar/wlr-which-key
  # já é linkada logo abaixo (xdg.configFile); os outros itens não têm
  # dotfile próprio (são referenciados de dentro do config do niri, já
  # linkado) ou não precisam de um. noctalia/qs via writeShellScriptBin
  # porque o noctalia-shell só existe no canal unstable (pkgs-unstable já
  # chega ao HM via home-manager.extraSpecialArgs, ver flake.nix).
  home.packages =
    (with pkgs; [
      swaylock
      swayidle
      grim # screenshot capture
      slurp # screen area selector (used with grim)
      swappy # screenshot annotation
      cliphist # clipboard history
      wl-clipboard
      xwayland-satellite
      waybar
      fuzzel # app launcher
      swaybg # wallpaper daemon
      wlr-which-key # keybinding cheatsheet popup
      orca # screen reader
      brightnessctl
      playerctl
      pavucontrol

      # Desktop integration
      networkmanagerapplet
      nextcloud-client
      capitaine-cursors
      qt6Packages.qt6ct # Qt theming control panel
      seahorse # GNOME Keyring GUI
    ])
    ++ [
      (pkgs.writeShellScriptBin "noctalia" ''
        exec ${pkgs-unstable.noctalia-shell}/bin/noctalia-shell "$@"
      '')
      (pkgs.writeShellScriptBin "qs" ''
        exec ${pkgs-unstable.noctalia-shell}/bin/noctalia-shell "$@"
      '')
    ];

  xdg.configFile = {
    # Compositor stack
    "niri" = {
      source = "${configs}/niri";
      recursive = true;
    };
    "waybar" = {
      source = "${configs}/waybar";
      recursive = true;
    };
    "wlr-which-key" = {
      source = "${configs}/wlr-which-key";
      recursive = true;
    };
  };
}
