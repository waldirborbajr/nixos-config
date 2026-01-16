# { config, ... }:
# let
#   GOPATH = "${config.home.homeDirectory}/go";
#   GOBIN = "${GOPATH}/bin";
# in
# {
#   # Install and configure Golang via home-manager module
#   programs.go = {
#     enable = true;
#     env = { inherit GOBIN GOPATH; };
#   };

#   # Ensure Go bin in the PATH
#   home.sessionPath = [
#     "$HOME/go/bin"
#   ];
# }

{ config, pkgs, ... }:

let
  goPath = "${config.home.homeDirectory}/go";
in
{
  programs.go = {
    enable = true;

    env = {
      GOPATH = goPath;
      GOBIN  = "${goPath}/bin";
    };
  };

  # Ferramentas Go (LSP, debug, lint, fmt)
  home.packages = with pkgs; [
    gopls                 # LSP
    delve                 # Debugger (dlv)
    goimports             # gofmt + imports
    golangci-lint         # Lint consolidado
    gotools               # guru, godoc, etc.
  ];
}
