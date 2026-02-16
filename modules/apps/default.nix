# modules/apps/default.nix
# Home-manager level applications with individual enable options
{ config, lib, ... }:

{
  imports = [
    # Core apps
    #./zsh.nix
    ./zsh/default.nix
    ./p10k/p10k.nix
    ./micro.nix
    ./bat.nix
    ./fzf.nix
    ./git.nix
    ./alacritty.nix
    ./wezterm.nix
    ./fastfetch.nix
    ./dev-tools.nix
    ./commitizen.nix
    ./ripgrep.nix
    ./yazi.nix
    ./tmux.nix
    ./chirp.nix
    ./lazygit.nix
    ./nix.nix

    # New apps (migrated from system)
    ./browsers.nix
    ./communication.nix
    ./helix.nix
    ./neovim.nix
    ./starship.nix
    ./ides.nix
    ./knowledge.nix
    ./remote.nix
    ./ssh-tools.nix
    ./termius.nix
    ./clipboard.nix
    ./swaync.nix
    ./network-manager.nix
    ./zellij.nix
    ./latex.nix
    ./fun-tools.nix
    ./screens.nix

    # Modular apps (Dendritic Pattern)
    ./media # Aggregator with submodules
    ./productivity # Aggregator with submodules

    # Virtualization tools (Home Manager level)
    ../virtualization/virtualbox.nix
    ../virtualization/distrobox.nix
  ];

  options.apps = {
    zsh = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable zsh shell with fzf and bat";
      };
    };

    bat = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable bat - cat clone with syntax highlighting";
      };
    };

    fzf = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fzf - command-line fuzzy finder";
      };
    };

    git = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable git version control system";
      };
    };

    alacritty = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Alacritty terminal emulator";
      };
    };

    wezterm = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable WezTerm terminal emulator (backup/reserve option)";
      };
    };

    fastfetch = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable fastfetch system info tool";
      };
    };

    dev-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable development tools (git, gh)";
      };
    };

    nix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Nix package manager configuration and tools";
      };
    };

    commitizen = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Commitizen for standardized git commits";
      };
    };

    ripgrep = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable ripgrep with DevOps optimizations";
      };
    };

    yazi = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable yazi file manager";
      };
    };

    tmux = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable tmux with Catppuccin theme";
      };
    };

    chirp = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Chirp ham radio programming tool";
      };
    };

    browsers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable web browsers (Firefox, Brave)";
      };
    };

    communication = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable communication tools (Vesktop)";
      };
    };

    helix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Helix editor";
      };
    };
    neovim = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Neovim editor";
      };
    };
    starship = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Starship prompt";
      };
    };
    ides = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable IDEs (VSCode)";
      };
    };

    knowledge = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable knowledge management tools (Obsidian)";
      };
    };

    # Media tools - now with granular options
    # Options defined in ./media/default.nix
    # Use: apps.media.enable = true; (all)
    # Or:  apps.media.image.enable = true; (specific)

    # Productivity tools - now with granular options
    # Options defined in ./productivity/default.nix
    # Use: apps.productivity.enable = true; (all)
    # Or:  apps.productivity.file-tools.enable = true; (specific)

    remote = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable remote access tools (AnyDesk)";
      };
    };

    ssh-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable SSH utilities and enhanced remote terminal tools (mosh, sshfs, etc.)";
      };
    };

    termius = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Termius SSH client with cloud sync";
      };
    };

    clipboard = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable clipboard and screenshot tools";
      };

      grimblast = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable grimblast - convenient wrapper for grim+slurp screenshot tool";
        };
      };
    };

    swaync = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable SwayNC notification center for Wayland";
      };
    };

    network-manager = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable NetworkManager applet (nm-applet) for system tray";
      };
    };

    wl-clip-persist = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable wl-clip-persist to persist clipboard content after application closes (Wayland)";
      };
    };

    hyprpicker = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable hyprpicker color picker for Hyprland/Wayland";
      };
    };

    screens = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable screen locking and display management tools";
      };

      hyprlock = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.apps.screens.enable;
          description = "Enable Hyprlock - screen locker for Hyprland";
        };
      };

      swaylock-effects = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = config.apps.screens.enable;
          description = "Enable Swaylock-effects - screen locker with effects for Sway/Wayland";
        };
      };
    };

    multiplexers = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "DEPRECATED: Use zellij.enable instead. This option remains for backwards compatibility.";
      internal = true;
    };

    zellij = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Zellij terminal multiplexer (tmux alternative)";
      };
    };

    latex = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable LaTeX typesetting system and tools";
      };
    };

    lazygit = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable lazygit terminal UI for git";
      };
    };

    # Virtualization tools
    virtualbox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable VirtualBox virtualization";
      };
    };

    distrobox = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Distrobox container tool";
      };
    };

    # Fun CLI tools
    cbonsai = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable cbonsai bonsai tree generator";
      };
    };

    cmatrix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable cmatrix Matrix-style screen";
      };
    };

    pipes = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable pipes animated pipes screen";
      };
    };

    tty-clock = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable tty-clock terminal clock";
      };
    };
  };
}
