# home/modules/editors.nix
#
# Git, bat e neovim. Helix fica isolado em home/modules/helix/ para seguir
# a estrutura modular do Foundry/Misterio77.
{
  pkgs-unstable,
  inputs,
  ...
}: let
  configs = ../configs;

  system = pkgs-unstable.stdenv.hostPlatform.system;

  # Troque para `true` no(s) host(s) onde quiser testar a 0.13-dev
  useNightlyNeovim = false;

  nvimPkg =
    if useNightlyNeovim
    then inputs.neovim-nightly-overlay.packages.${system}.default
    else pkgs-unstable.neovim;
in {
  imports = [
    ./helix
  ];

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

  home.packages = [nvimPkg];

  xdg.configFile = {
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };

    "helix" = {
      source = "${configs}/helix";
      recursive = true;
    };

    "nvim" = {
      source = "${configs}/nvim";
      recursive = true;
    };
  };
}
