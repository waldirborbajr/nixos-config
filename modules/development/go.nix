{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Somente ferramentas específicas do ecossistema Go.
  environment.systemPackages = with pkgs; [
    go_1_25
    gopls
    gotools
    gomodifytags
    gotests
    gore
    gofumpt
    golangci-lint
    golangci-lint-langserver
    go-task
    air
    goreleaser
    impl
    delve
  ];
}
