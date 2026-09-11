{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf config.development.languages.python.enable {
    # Somente Python e ferramentas específicas do ecossistema Python.
    # uv2nix/pyproject-nix continua sendo responsabilidade dos devshells
    # por projeto; aqui instalamos as ferramentas que precisam estar
    # disponíveis no ambiente de desenvolvimento geral.
    environment.systemPackages = with pkgs; [
      python313
      uv
      python313Packages.python-lsp-server
      black
      ruff
    ];
  };
}
