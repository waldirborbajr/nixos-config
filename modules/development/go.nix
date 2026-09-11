{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    godef
    go
    gopls # LSP server
    gotools # Includes goimports, guru, etc.
    gomodifytags # For struct tag manipulation
    gotests # Test generation
    gore # Go REPL (if you actually use it)
    golangci-lint # Linting
    delve # Debugger

    # Resto do commonBuildInputs do devshells/go que tinha ficado de fora
    gofumpt
    golangci-lint-langserver
    go-task
    air
    watchexec
    goreleaser
    impl
    sqlite
    sqlite-analyzer
    jq
    ripgrep
    fd
    tree
    gdb
    pkg-config
    openssl
    zlib
    # helix
  ];
}
