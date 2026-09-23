# modules/root_pkgs.nix
#
# allowUnfree, config do Nix (gc/optimise/settings) e o núcleo mínimo de
# pacotes de sistema — o que precisa existir mesmo se a ativação do
# home-manager falhar (root e serviços usam environment.systemPackages,
# não o HM do usuário).
#
# Tudo que é ferramenta de usuário (CLI extra, desktop niri/waybar) foi
# migrado pro home-manager, onde tem dono único e — quando existe
# home/configs/<algo> — a config já linkada (ver home/desktop.nix e
# home/cli-and-terminal.nix). Ver features.nix pro painel de
# linguagens/containers.
{pkgs, ...}: {
  # ==================== PROGRAMS ====================
  nixpkgs.config.allowUnfree = true;

  # environment.shellAliases = {
  #   vi = "hx";
  #   vim = "hx";
  #   nvim = "hx";
  # };

  # ==================== PACKAGES (núcleo mínimo, fora do painel) ====================
  # git → modules/dev/base.nix. zsh/eza/zoxide/bat/fzf/delta/direnv →
  # home/shell.nix e home/cli-and-terminal.nix (HM), removidos daqui pra
  # não ter dois donos pro mesmo binário.
  environment.systemPackages = with pkgs; [
    wget
    curl
    expect # scripts/logitech-k380-bluetooth-linux-fix/*.exp

    # ---- Secrets (usados por scripts fora do HM: manage-ssh-sops.sh etc.) ----
    age
    sops

    # ---- System monitoring básico (root/serviços também usam) ----
    htop
  ];

  # ==================== NIX ====================
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  nix.optimise.automatic = true;

  # nix.settings.experimental-features = [\"nix-command\" \"flakes\"];
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      # "https://vicinae.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      # "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
