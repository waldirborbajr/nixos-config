# modules/apps/productivity/default.nix
# Productivity tools aggregator - Dendritic Pattern
{ config, lib, ... }:

{
  imports = [
    ./file-tools.nix
    ./navigation.nix
    ./shell-history.nix
    ./text-processing.nix
    ./http-clients.nix
    ./workflow.nix
    ./monitoring.nix
    ./git-ui.nix
  ];

  options.apps.productivity = {
    # Single enable for all productivity tools (backward compatibility)
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable all modern CLI productivity tools";
    };

    # Granular controls
    file-tools = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable modern file operations tools (eza, fd, dust, ncdu, tree)";
      };
    };

    navigation = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable smart directory navigation (zoxide)";
      };
    };

    shell-history = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable enhanced shell history (atuin)";
      };
    };

    text-processing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable text and data processing tools (sd, jq, fx, tldr)";
      };
    };

    http-clients = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable HTTP clients (httpie)";
      };
    };

    workflow = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable workflow automation (direnv, entr)";
      };
    };

    monitoring = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable system monitoring tools (procs, btop)";
      };
    };

    git-ui = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.apps.productivity.enable;
        description = "Enable Git terminal UI (lazygit)";
      };
    };
  };
}
