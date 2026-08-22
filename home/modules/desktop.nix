# home/modules/desktop.nix
#
# Notificações (mako), keyring de sessão e a parte do compositor
# niri/waybar/wlr-which-key comum a todos os hosts (overrides por host
# ficam em hosts/<host>/default.nix). Extraído 1:1 de home/default.nix
# (split cirúrgico, sem mudança de comportamento).
{...}: let
  configs = ../configs;
in {
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
