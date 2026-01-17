{ config, pkgs, ... }:

let
  goPath = "${config.home.homeDirectory}/go";
in
{
  ############################################
  # Go language support (Home Manager)
  ############################################
  programs.go = {
    enable = true;

    env = {
      GOPATH = goPath;
      GOBIN = "${goPath}/bin";
    };
  };

  ############################################
  # Ensure Go binaries are on PATH
  ############################################
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  ############################################
  # Go development tools
  ############################################
  home.packages = [
    pkgs.gopls # LSP
    pkgs.delve # Debugger (dlv)
    pkgs.goimports # gofmt + imports
    pkgs.golangci-lint # Linter all-in-one
    pkgs.gotools # guru, godoc, etc.
  ];
}
