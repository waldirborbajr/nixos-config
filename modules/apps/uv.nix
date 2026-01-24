# modules/apps/uv.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    uv          # pacote principal (inclui uv venv, uv pip, uv tool, etc.)
    python312   # ou python311 / python313 – escolha a versão padrão que você usa
                # (uv consegue usar qualquer Python instalado via Nix)
  ];

  # Opcional: variáveis de ambiente para uv se comportar melhor no NixOS
  environment.sessionVariables = {
    # Evita que uv crie venvs em locais estranhos
    UV_PYTHON_DOWNLOADS = "never";  # usa só Pythons do Nix (recomendado)
    UV_PYTHON = "${pkgs.python312}/bin/python";  # versão default (opcional)
  };

  # Dicas no shell (opcional, mas ajuda muito)
  programs.zsh.interactiveShellInit = ''
    # uv aliases / helpers úteis
    alias uv-init="uv venv --python $(which python) && source .venv/bin/activate && uv add --dev ruff black mypy pytest"
    alias uv-sync="uv sync --frozen"  # instala do uv.lock sem atualizar

    # Lembrete rápido
    echo "uv dicas:"
    echo "  uv venv          → cria .venv"
    echo "  uv pip install X → instala no venv ativo"
    echo "  uv tool install X → instala tools globais (ex: ruff, black)"
    echo "  uv python list   → lista Pythons disponíveis"
  '';
}
