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
    pkgs.gopls
    pkgs.delve
    pkgs.goPackages.goimports # ✅ CORRETO
    pkgs.golangci-lint
    pkgs.gotools
  ];
}
