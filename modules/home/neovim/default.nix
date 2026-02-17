# modules/apps/neovim.nix
# Neovim editor
# NOTE: Neovim configured via dotfiles (stow), no plugins managed here
{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf config.apps.neovim.enable {
    home.packages = with pkgs; [
      neovim
      # Tree-sitter CLI and grammars for neovim
      tree-sitter
    ];

    # Install tree-sitter grammars system-wide to avoid dynamic compilation
    home.file.".local/share/nvim/nix-treesitter".source =
      "${pkgs.vimPlugins.nvim-treesitter.withAllGrammars}/parser";

    home.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      SUDO_EDITOR = "nvim";
    };
  };
}
