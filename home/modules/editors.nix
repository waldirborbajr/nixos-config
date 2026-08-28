# home/modules/editors.nix
#
# Git, bat e neovim. Helix fica isolado em home/modules/helix/ para seguir
# a estrutura modular do Foundry/Misterio77.
{pkgs-unstable, ...}: let
  configs = ../configs;
in {
  imports = [
    ./helix
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "Waldir Borba Junior";
      user.email = "wborbajr@gmail.com";
      core.editor = "nvim";
      core.pager = "bat";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.bat.enable = true;

  # neovim — declarado aqui porque este módulo é importado por todos os
  # hosts (NixOS + macOS standalone).
  home.packages = [pkgs-unstable.neovim];

  xdg.configFile = {
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };

    "nvim" = {
      source = "${configs}/nvim";
      recursive = true;
    };
  };
}
