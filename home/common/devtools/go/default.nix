{ config, pkgs, ... }:

let
  goPath = "${config.home.homeDirectory}/go";
in
{
  ############################################
  # Go (Home Manager)
  ############################################
  programs.go = {
    enable = true;

    env = {
      GOPATH = goPath;
      GOBIN = "${goPath}/bin";
    };
  };

  ############################################
  # Ensure Go binaries are in PATH
  ############################################
  home.sessionPath = [
    "$HOME/go/bin"
  ];

  ############################################
  # Go development tools
  ############################################
  home.packages = with pkgs; [
    gopls # LSP
    delve # Debugger
    golangci-lint # Linter
    gotools # ✅ includes goimports (OFICIAL)
  ];
}
