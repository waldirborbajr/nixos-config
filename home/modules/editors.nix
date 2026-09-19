# home/modules/editors.nix
#
# Só editores de texto: Helix (core, sempre instalado, sem toggle),
# Neovim e Emacs vanilla (enable=true/false, default false, ativado
# pontualmente na máquina). Git/bat/delta não são editores — moraram
# em home/modules/cli-and-terminal.nix.
{
  pkgs-unstable,
  inputs,
  lib,
  config,
  ...
}: let
  configs = ../configs;

  system = pkgs-unstable.stdenv.hostPlatform.system;

  nvimPkg =
    if config.editors.neovim.nightly
    then inputs.neovim-nightly-overlay.packages.${system}.default
    else pkgs-unstable.neovim;
in {
  imports = [
    ./helix
  ];

  options.editors = {
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

    xdg.configFile = lib.optionalAttrs config.editors.neovim.enable {
      "nvim" = {
        source = "${configs}/nvim";
        recursive = true;
      };
    };
  };
}
