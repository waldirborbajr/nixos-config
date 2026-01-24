# modules/apps/go.nix
{ config, pkgs, lib, ... }:

{
  # Toolchain Go + LSP + debugger (versão estável mais recente em 2026)
  home.packages = with pkgs; [
    go_1_25          # ou go_1_22 / go_1_24 dependendo do seu projeto principal
    gopls            # LSP para Neovim / VSCode
    delve            # debugger oficial do Go
    gotools          # goimports, gorename, etc.
    gofumpt          # formatter mais estrito que gofmt
    golangci-lint    # linter completo
  ];

  # Variáveis de ambiente úteis para Go
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN  = "${config.home.homeDirectory}/go/bin";
    PATH   = "${config.home.homeDirectory}/go/bin:$PATH";
  };

  # Opcional: aliases rápidos para comandos comuns de Go/DevOps
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    goi   = "go install ./...";             # instala binários do projeto
    got   = "go test ./... -v";             # roda todos os testes com verbose
    gotc  = "go test -coverprofile=cover.out ./...";  # cobertura
    goc   = "go clean -cache -modcache";    # limpa cache
    goup  = "go get -u ./...";              # atualiza dependências
    gom   = "go mod tidy";                  # limpa go.mod/go.sum
    gorf  = "gofumpt -w .";                 # formata com gofumpt
    gol   = "golangci-lint run";            # roda linter
  };

  # Opcional: ativação para garantir GOPATH criado
  home.activation = {
    ensureGoPath = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p $HOME/go/{bin,pkg,src}
    '';
  };
}
