# home/editors.nix
#
# Só editores de texto: Helix, Neovim e Emacs vanilla — todos com
# enable=true/false. Helix nasce true (é o "core" de hoje); Neovim e
# Emacs nascem false, ativados pontualmente na máquina. Git/bat/delta
# não são editores — moram em home/cli-and-terminal.nix.
#
# $EDITOR/$VISUAL são calculados aqui dinamicamente a partir de qual
# editor está ligado (prioridade: Helix > Neovim > Emacs), em vez de
# fixados como "hx" espalhado por vários arquivos. O git NÃO tem mais
# core.editor no home/configs/git/config — sem essa linha, o git cai
# sozinho no $VISUAL/$EDITOR do ambiente, então também segue essa
# mesma prioridade automaticamente.
{
  pkgs-unstable,
  inputs,
  lib,
  config,
  ...
}: let
  configs = ./configs;

  system = pkgs-unstable.stdenv.hostPlatform.system;

  nvimPkg =
    if config.editors.neovim.nightly
    then inputs.neovim-nightly-overlay.packages.${system}.default
    else pkgs-unstable.neovim;

  cfg = config.editors;

  # Terminal-only pra qualquer um dos três (Emacs sem daemon/GUI, só o
  # binário `emacs -nw`) — evita abrir GUI no meio de um `git commit`
  # rodado num terminal puro.
  activeEditor =
    if cfg.helix.enable
    then "hx"
    else if cfg.neovim.enable
    then "nvim"
    else if cfg.emacs.enable
    then "emacs -nw"
    else null; # nenhum editor ligado — $EDITOR fica por conta do sistema
in {
  imports = [
    ./helix
  ];

  options.editors = {
    helix.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Helix (config.toml/languages.toml/tema linkados de home/configs/helix/). Editor \"core\" de hoje — default true.";
    };

    emacs.enable = lib.mkEnableOption "Emacs vanilla (corfu/eglot/eat, ver emacs-vanilla.nix)";

    neovim = {
      enable = lib.mkEnableOption "Neovim";
      nightly = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Usa o neovim-nightly-overlay em vez do neovim estável do nixpkgs-unstable. Só tem efeito com editors.neovim.enable = true.";
      };
    };
  };

  config = {
    home.packages = lib.optional config.editors.neovim.enable nvimPkg;

    home.sessionVariables = lib.optionalAttrs (activeEditor != null) {
      EDITOR = activeEditor;
      VISUAL = activeEditor;
    };

    xdg.configFile = lib.optionalAttrs config.editors.neovim.enable {
      "nvim" = {
        source = "${configs}/nvim";
        recursive = true;
      };
    };
  };
}
