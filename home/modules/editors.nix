# home/modules/editors.nix
#
# Git, bat, Neovim e Emacs vanilla. Neovim e Emacs seguem o mesmo padrão
# do resto do repo (containerTools, development.languages): default
# false, ativado pontualmente na máquina que for usar. Helix continua
# isolado em home/modules/helix/ e é o editor "core" (git core.editor),
# sempre instalado, sem toggle.
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
    programs.git = {
      enable = true;
      settings = {
        user.name = "Waldir Borba Junior";
        user.email = "wborbajr@gmail.com";
        core.editor = "hx";
        core.pager = "bat";
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };

    programs.bat.enable = true;

    home.packages = lib.optional config.editors.neovim.enable nvimPkg;

    xdg.configFile =
      {
        "bat" = {
          source = "${configs}/bat";
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