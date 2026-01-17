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

    # Qt theming (CORRETO para nixpkgs unstable)
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  ############################################
  # VARIÁVEIS DE AMBIENTE (HOME)
  ############################################
  home.sessionVariables = {
    # Wayland por padrão
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";

    # Qt theme control
    QT_QPA_PLATFORMTHEME = "qt5ct";
  };
}
