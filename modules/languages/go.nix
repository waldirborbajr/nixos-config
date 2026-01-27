# modules/languages/go.nix
# Go development environment
{ config, pkgs, lib, ... }:

let
  enableGo = true;  # true | false
in
{
  # ========================================
  # Go packages (global)
  # ========================================
  home.packages = lib.optionals enableGo (with pkgs; [
    go_1_25
    gopls            # LSP
    delve            # Debugger
    gotools          # goimports, gorename, etc
    gofumpt          # Formatter
    golangci-lint    # Linter
    go-task          # Task runner (alternative to Make)
    air              # Hot reload
  ]);

  # ========================================
  # Environment variables
  # ========================================
  home.sessionVariables = lib.mkIf enableGo {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN  = "${config.home.homeDirectory}/go/bin";
  };

  # ========================================
  # Shell aliases
  # ========================================
  programs.zsh.shellAliases = lib.mkIf (enableGo && config.programs.zsh.enable) {
    goi   = "go install ./...";
    got   = "go test ./... -v";
    gotc  = "go test -coverprofile=cover.out ./...";
    goc   = "go clean -cache -modcache";
    goup  = "go get -u ./...";
    gom   = "go mod tidy";
    gorf  = "gofumpt -w .";
    gol   = "golangci-lint run";
    gorun = "go run .";
    gob   = "go build -v ./...";
  };

  # ========================================
  # Home activation (ensure GOPATH)
  # ========================================
  home.activation = lib.mkIf enableGo {
    ensureGoPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/go/{bin,pkg,src}
    '';
  };
}
