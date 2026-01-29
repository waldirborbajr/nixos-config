# home.nix
{ config, pkgs, lib, hostname, ... }:

let
  isMacbook = (hostname == "macbook-nixos") || (hostname == "macbook");
in
{
  home.stateVersion = "25.11";
  home.username = "borba";
  home.homeDirectory = lib.mkForce "/home/borba";

  imports = [
    # Theme (home-manager level)
    ./modules/themes

    # Apps (all available, enable below)
    ./modules/apps

    # Languages (all available, enable below)
    ./modules/languages
  ] ++ lib.optionals isMacbook [
    ./modules/desktops/niri
  ];

  # ==========================================
  # Enable apps via options
  # ==========================================
  apps = {
    shell.enable = true;
    terminals.enable = true;
    fastfetch.enable = true;
    dev-tools.enable = true;
    ripgrep.enable = true;
    yazi.enable = true;
    tmux.enable = true;
    chirp.enable = false;  # Only enable if needed
  };

  # ==========================================
  # Enable languages via options (home-manager level only)
  # ==========================================
  languages = {
    go.enable = false;        # Enable per-project
    rust.enable = false;      # Enable per-project
    lua.enable = false;       # Enable if using Neovim plugins
    nix-dev.enable = true;    # Always useful for NixOS
  };

  home.packages = with pkgs; [
    zoxide
    eza
    fd
    tree
  ] ++ lib.optionals isMacbook (with pkgs; [
    waybar
    mako
    fuzzel
    wl-clipboard
    grim
    slurp
    swappy
    playerctl
  ]);

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    BROWSER = "com.brave.Browser";
    TERMINAL = "alacritty";
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND = "false";
    NPM_CONFIG_AUDIT = "false";
    PYTHONDONTWRITEBYTECODE = "1";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };
}
