# home/modules/emacs.nix
#
# Emacs com tema OneNord + suporte a Rust, Go, Lua e Nix via eglot
# (LSP built-in) e treesit-auto. Config crua vive em home/configs/emacs/
# e é linkada inteira pra ~/.config/emacs, mesmo padrão usado pra
# nvim/bat em home/modules/editors.nix.
#
# Os language servers (rust-analyzer, gopls, lua-language-server, nixd)
# não são instalados aqui de propósito — já estão nos devshells/ e/ou
# em home/modules/helix/ (config.toml aponta pros mesmos binários).
# Se quiser que funcionem fora de um devshell, adicione os pacotes em
# home.packages (ver comentário abaixo).
{pkgs, ...}: let
  configs = ../configs;
in {
  home.packages = [
    pkgs.emacs
    # Descomente para ter os LSPs disponíveis fora de devshells/:
    # pkgs.rust-analyzer
    # pkgs.gopls
    # pkgs.lua-language-server
    # pkgs.nixd
  ];

  xdg.configFile."emacs" = {
    source = "${configs}/emacs";
    recursive = true;
  };
}
