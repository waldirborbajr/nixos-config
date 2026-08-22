# modules/nixos/packages.nix
#
# allowUnfree, editor padrão, aliases de shell, lista de pacotes do
# sistema e configuração do Nix (gc/optimise/settings). Extraído 1:1 de
# configuration.nix (split cirúrgico, sem mudança de comportamento).
{
  pkgs,
  pkgs-unstable,
  ...
}: {
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
      # ---- Shell & CLI core (fetch, files, search) ----
      wget
      curl
      atuin # shell history sync/search
      expect
      ripgrep
      eza # ls replacement
      zoxide # cd replacement
      bat # cat with syntax highlighting
      tmux
      fzf

      # ---- Version control ----
      git
      gh # GitHub CLI
      gh-dash # GitHub CLI TUI dashboard
      delta # git diff pager

      # ---- Document viewers ----
      zathura # PDF/document viewer
      mupdf # lightweight PDF renderer/tools

      # ---- Config file linters/formatters (KDL, TOML — niri/waybar configs, Cargo.toml, etc.) ----
      kdlfmt
      taplo

      # ---- Archive / compression ----
      unzip
      zip
      p7zip # 7z (handles several other formats too)
      xarchiver # lightweight GTK GUI for zip/7z/tar/rar extraction —
      # fits a minimal niri/waybar setup better than file-roller
      # (avoids pulling in heavy GNOME dependencies)

      # ---- System monitoring / info ----
      btop
      htop
      fastfetch

      # ---- Shell / prompt / terminal ----
      zsh
      oh-my-posh
      # alacritty
      wezterm

      # ---- Nix tooling ----
      nixd # Nix language server
      alejandra # Nix formatter (also wired into `nix fmt` via treefmt.nix)

      # ---- Secrets ----
      age
      sops

      # ---- Wayland session / niri desktop ----
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

      # ---- Desktop integration ----
      networkmanagerapplet
      nextcloud-client
      capitaine-cursors
      qt6Packages.qt6ct # Qt theming control panel
      seahorse # GNOME Keyring GUI
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

  # nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = ["https://vicinae.cachix.org"];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
    ];
  };
}
