# modules/apps/poetry.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    poetry
    python312  # mesma versão base do uv.nix para consistência
  ];

  # Configurações recomendadas para Poetry no NixOS
  environment.sessionVariables = {
    POETRY_VIRTUALENVS_IN_PROJECT = "true";  # cria .venv dentro do projeto (padrão moderno)
    POETRY_VIRTUALENVS_CREATE = "true";
    POETRY_VIRTUALENVS_PATH = "./.venv";     # força dentro do projeto (evita ~/.cache)
  };

  # Helpers no shell (opcional)
  programs.zsh.interactiveShellInit = ''
    # poetry aliases úteis
    alias poe-init="poetry init && poetry add --group dev ruff black mypy pytest pre-commit"
    alias poe-install="poetry install --sync"
    alias poe-shell="poetry shell"
    alias poe-run="poetry run"

    echo "poetry dicas:"
    echo "  poetry new meu-projeto     → cria estrutura"
    echo "  poetry add httpx           → adiciona dep"
    echo "  poetry add --group dev ... → dev deps"
    echo "  poetry lock --no-update    → atualiza lock sem mudar versões"
  '';
}
