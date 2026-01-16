# { pkgs, ... }:
# {
#   # Neovim text editor configuration
#   programs.neovim = {
#     enable = true;
#     package = pkgs.neovim-unwrapped;
#     defaultEditor = true;
#     withNodeJs = true;
#     withPython3 = true;
#     withRuby = true;

#     extraPackages = with pkgs; [
#       black
#       golangci-lint
#       gopls
#       gotools
#       hadolint
#       isort
#       lua-language-server
#       markdownlint-cli
#       nixd
#       nixfmt
#       nodePackages.bash-language-server
#       nodePackages.prettier
#       pyright
#       ruff
#       shellcheck
#       shfmt
#       stylua
#       terraform-ls
#       tflint
#       tree-sitter
#       vscode-langservers-extracted
#       yaml-language-server
#     ];
#   };

#   # source lua config from this repo
#   xdg.configFile = {
#     "nvim" = {
#       source = ./lazyvim;
#       recursive = true;
#     };
#   };
# }

{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;

    # withNodeJs = true;
    # withPython3 = true;
    # withRuby = true;

    # extraPackages = with pkgs; [
    #   # 🐍 Python
    #   black
    #   isort
    #   pyright
    #   ruff

    #   # 🐹 Go
    #   gopls
    #   gotools
    #   golangci-lint

    #   # 🦀 Rust (já vem via rust-overlay)
    #   # rust-analyzer vem da toolchain

    #   # 🐚 Shell / DevOps
    #   shellcheck
    #   shfmt
    #   hadolint

    #   # 🌍 Web / Lua
    #   stylua
    #   lua-language-server
    #   nodePackages.prettier
    #   nodePackages.bash-language-server
    #   vscode-langservers-extracted

    #   # 🧾 Infra
    #   terraform-ls
    #   tflint
    #   yaml-language-server

    #   # ❄️ Nix
    #   nixd
    #   nil
    #   nixfmt-rfc-style
    #   statix
    #   deadnix
    # ];
  };

  # 🔗 Usa sua config madura do LazyVim
  xdg.configFile."nvim" = {
    source = ./lazyvim;
    recursive = true;
  };
}
