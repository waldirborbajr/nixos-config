# home/modules/desktop.nix
#
# Notificações (mako), keyring de sessão e a parte do compositor
# niri/waybar/wlr-which-key comum a todos os hosts (overrides por host
# ficam em hosts/<host>/default.nix). Extraído 1:1 de home/default.nix
# (split cirúrgico, sem mudança de comportamento).
{pkgs, ...}: let
  configs = ../configs;
in {
  # ==================== GTK / ÍCONES (sessão real, não o greeter) ====================
  # O Papirus-Dark em modules/nixos/desktop-niri.nix só é usado pelo regreet
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
    components = ["pkcs11" "secrets" "ssh"];
  };

  # Se quiser usar o keyring como SSH agent:
  home.sessionVariables.SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/keyring/ssh";

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
