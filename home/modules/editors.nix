# home/modules/editors.nix
#
# Git (config linkado direto de home/configs/git/, já com tudo definido
# lá — sem passar pelas opções estruturadas programs.git.settings/delta),
# bat, Neovim e Emacs vanilla. Neovim e Emacs seguem o padrão
# enable=true/false do resto do repo (default false, ativado
# pontualmente na máquina). Helix continua isolado em
# home/modules/helix/ e é o editor "core", sempre instalado, sem toggle.
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
    # Só liga o programa (garante o pacote `git` no PATH); a config em
    # si (user, core, pull, delta etc.) vem inteira do link abaixo.
    programs.git.enable = true;

    programs.bat.enable = true;

    home.packages = lib.optional config.editors.neovim.enable nvimPkg;

    xdg.configFile =
      {
        "bat" = {
          source = "${configs}/bat";
          recursive = true;
        };

        "git" = {
          source = "${configs}/git";
          recursive = true;
        };

        # Helix NÃO é linkado aqui: home/modules/helix/default.nix já linka
        # cada arquivo individualmente (config.toml, languages.toml, tema,
        # yazi-picker.sh) com onChange/executable próprios. Um link
        # recursivo da pasta inteira aqui colidiria com esses mesmos alvos.
      }
      // lib.optionalAttrs config.editors.neovim.enable {
        "nvim" = {
          source = "${configs}/nvim";
          recursive = true;
        };
      };
  };
}
