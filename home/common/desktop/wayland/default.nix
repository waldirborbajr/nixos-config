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
    waybar                 # barra de status Wayland
    rofi-wayland           # launcher nativo Wayland (preferir ao rofi X11)

    ####################
    # Clipboard
    ####################
    wl-clipboard           # clipboard nativo
    cliphist               # histórico de clipboard (opcional, mas recomendado)

    ####################
    # Screenshot / Screencast
    ####################
    grim                   # screenshot
    slurp                  # seleção de área
    swappy                 # editor de screenshot
    wf-recorder            # gravação de tela (Wayland)

    ####################
    # Input / automação
    ####################
    wtype                  # simulação de teclado (scripts, automações)

    ####################
    # Utilitários Wayland
    ####################
    wayland-utils          # wayland-info (debug)
    wlr-randr              # controle de monitores

    ####################
    # Lock / idle / logout
    ####################
    swaylock               # lockscreen
    swayidle               # idle manager
    wlogout                # menu de logout

    ####################
    # UX / Qualidade visual
    ####################
    nwg-look               # configuração GTK
    qt5ct                  # controle Qt5
    qt6ct                  # controle Qt6
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
