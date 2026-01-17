# { pkgs, ... }:

# {
#   home.packages = with pkgs; [
#     waybar
#     rofi
#     wl-clipboard
#   ];
# }

{ pkgs, ... }:

{
  ############################################
  # WAYLAND — PACOTES DE USUÁRIO (HOME)
  ############################################
  home.packages = with pkgs; [

    ####################
    # Status bar / launcher
    ####################
    waybar
    rofi

    ####################
    # Clipboard
    ####################
    wl-clipboard
    cliphist

    ####################
    # Screenshot / Screencast
    ####################
    grim
    slurp
    swappy
    wf-recorder

    ####################
    # Input / automação
    ####################
    wtype

    ####################
    # Utilitários Wayland
    ####################
    wayland-utils
    wlr-randr

    ####################
    # Lock / idle / logout
    ####################
    swaylock
    swayidle
    wlogout

    ####################
    # UX / Qualidade visual
    ####################
    nwg-look
    libsForQt5.qt5ct
    qt6ct
  ];

  ############################################
  # VARIÁVEIS DE AMBIENTE (HOME)
  ############################################
  home.sessionVariables = {
    # Força apps Chromium a usar Wayland
    NIXOS_OZONE_WL = "1";

    # Firefox Wayland
    MOZ_ENABLE_WAYLAND = "1";
  };

  ############################################
  # ─────────────────────────────────────────
  # ABAIXO: CONFIGURAÇÕES DE SISTEMA (NixOS)
  # ─────────────────────────────────────────
  #
  # ⚠️ NÃO FUNCIONAM NO HOME MANAGER
  # Copie para: common/programs ou configuration.nix
  ############################################

  /*
    ############################################
    # XDG DESKTOP PORTALS (SYSTEM)
    ############################################
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
      ];
    };
  */

  /*
    ############################################
    # ÁUDIO MODERNO (PIPEWIRE) — SYSTEM
    ############################################
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      jack.enable = true;
    };
  */

  /*
    ############################################
    # PERFORMANCE / WAYLAND GLOBAL (SYSTEM)
    ############################################
    environment.variables = {
      NIXOS_OZONE_WL = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  */
}
