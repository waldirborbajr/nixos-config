# home/default.nix
# Home Manager configuration for user borba — Fase 3.
#
# Dotfile contents now live inside the flake (home/configs/).
# No external ~/dotfiles dependency for managed programs.
#
# Strategy:
#   • Prefer native programs.* modules when they are expressive and stable.
#   • Fall back to xdg.configFile / home.file for complex trees
#     (niri, waybar, nvim, zellij, wezterm, full zsh ZDOTDIR, …).
#   • Host-specific overrides (niri/input.kdl) stay in the host modules.
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
  homeDir = "/home/${username}";
  configs = ./configs;
in {
  # ------------------------------------------------------------------
  # Identity
  # ------------------------------------------------------------------
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "26.05";

  xdg.enable = true;

# home/default.nix

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

  # ------------------------------------------------------------------
  # Shell (ZDOTDIR layout preserved)
  # ------------------------------------------------------------------
  # .zshenv must live outside ZDOTDIR.
  home.file.".zshenv".source = "${configs}/zshenv";

  # ZDOTDIR contents (everything except the zshenv file itself)
  xdg.configFile."zsh" = {
    source = "${configs}/zsh";
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    # Content comes from the ZDOTDIR tree; do not let HM emit its own .zshrc.
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # ------------------------------------------------------------------
  # Native modules (improvements over raw file linking)
  # ------------------------------------------------------------------

  # Git — fully structured; the old config file is no longer needed as source.
  programs.git = {
    enable = true;
    settings = {
      user.name = "Waldir Borba Junior";
      user.email = "wborbajr@gmail.com";
      core.editor = "nvim";
      core.pager = "bat";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Helix — native settings + languages (was config.toml + languages.toml)
  programs.helix = {
    enable = true;
    settings = lib.importTOML "${configs}/helix/config.toml";
    languages = lib.importTOML "${configs}/helix/languages.toml";
  };

  # Bat — enable + keep custom theme via xdg
  programs.bat.enable = true;

  # Btop
  programs.btop.enable = true;

  # Tmux — package + full conf file
  programs.tmux.enable = true;

  # ------------------------------------------------------------------
  # File-based configs (complex trees or no mature module)
  # ------------------------------------------------------------------
  xdg.configFile = {
    # Terminals
    "alacritty" = {
      source = "${configs}/alacritty";
      recursive = true;
    };
    "wezterm" = {
      source = "${configs}/wezterm";
      recursive = true;
    };

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

    # Editors / multiplexers
    "nvim" = {
      source = "${configs}/nvim";
      recursive = true;
    };
    "zellij" = {
      source = "${configs}/zellij";
      recursive = true;
    };
    "tmux" = {
      source = "${configs}/tmux";
      recursive = true;
    };

    # CLI tools that need extra files (themes, full conf)
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };
    "btop" = {
      source = "${configs}/btop";
      recursive = true;
    };
    "ripgrep" = {
      source = "${configs}/ripgrep";
      recursive = true;
    };
    "oh-my-posh" = {
      source = "${configs}/oh-my-posh";
      recursive = true;
    };
    "lazygit" = {
      source = "${configs}/lazygit";
      recursive = true;
    };

    # Extra helix script not covered by the module
    "helix/yazi-picker.sh" = {
      source = "${configs}/helix/yazi-picker.sh";
      executable = true;
    };
  };

  # ------------------------------------------------------------------
  # Session
  # ------------------------------------------------------------------
  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # Pure-user packages can migrate here over time.
  home.packages = [ ];
}
