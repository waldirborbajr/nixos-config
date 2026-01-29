# modules/apps/default.nix
# Home-manager level applications with individual enable options
{ config, lib, ... }:

{
  imports = [
    ./shell.nix
    ./terminals.nix
    ./fastfetch.nix
    ./dev-tools.nix
    ./ripgrep.nix
    ./yazi.nix
    ./tmux.nix
    ./chirp.nix
  ];

  options.apps = {
    shell = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable zsh shell with fzf and bat";
      };
    };

    terminals = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable terminal emulator (alacritty)";
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
  };
}
