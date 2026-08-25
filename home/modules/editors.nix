# home/modules/editors.nix
#
# Git, Helix (+ script auxiliar) e bat/nvim. Extraído 1:1 de
# home/default.nix (split cirúrgico, sem mudança de comportamento).
{
  pkgs,
  lib,
  ...
}: let
  configs = ../configs;
in {
  # Git — fully structured; the old config file is no longer needed as source.
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

  # Helix — native settings + languages (was config.toml + languages.toml)
  programs.helix = {
    enable = true;
    settings = lib.importTOML "${configs}/helix/config.toml";
    languages = lib.importTOML "${configs}/helix/languages.toml";
  };

  # Bat — enable + keep custom theme via xdg
  programs.bat.enable = true;

  # neovim — declarado aqui (não em modules/nixos/packages.nix) porque
  # este módulo é importado por TODOS os hosts (os 4 NixOS via
  # home/default.nix + o `macbook` standalone via hosts/macbook/home.nix),
  # então uma única declaração cobre todo mundo. É preciso mesmo: git
  # settings.core.editor="nvim" acima e os dotfiles compartilhados do zsh
  # (home/configs/zsh/aliases.zsh, functions.zsh) chamam `nvim` direto.
  # Antes vinha de environment.systemPackages nos hosts NixOS — o
  # `macbook` (sem essa camada) não tinha e quebrava; consolidado aqui
  # pra não precisar declarar de novo por host.
  home.packages = [pkgs.neovim];

  xdg.configFile = {
    "bat" = {
      source = "${configs}/bat";
      recursive = true;
    };

    "nvim" = {
      source = "${configs}/nvim";
      recursive = true;
    };

    # Extra helix script not covered by the module
    "helix/yazi-picker.sh" = {
      source = "${configs}/helix/yazi-picker.sh";
      executable = true;
    };
  };
}
