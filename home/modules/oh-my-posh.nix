# home/modules/oh-my-posh.nix
#
# MIGRAÇÃO: antes era `home.packages = [ oh-my-posh ]` (em
# cli-and-terminal.nix) + xdg.configFile apontando pra
# home/configs/oh-my-posh/zen.toml.
#
# Escolha deliberada, diferente de btop/fastfetch/atuin/yazi: o tema
# tem 113 linhas de TOML aninhado — convertido à mão pra attrset, um
# erro de transcrição quebraria o prompt de um jeito sutil, sem quebrar
# o build, e eu não tenho como testar renderizar aqui. Mantive o
# conteúdo como texto embutido em vez de reescrever em attrset.
# `enableZshIntegration` fica desligado de propósito: o eval do
# oh-my-posh já vive dentro do .zshrc embutido (home/modules/shell.nix)
# — ligar aqui duplicaria a inicialização.
#
# home/configs/oh-my-posh.old/ guarda o original (renomeado, não apagado).
{
  pkgs,
  lib,
  config,
  ...
}: let
  configs = ../configs;
in {
  home.packages = [pkgs.oh-my-posh];

  xdg.configFile."oh-my-posh/zen.toml".text = builtins.readFile "${configs}/oh-my-posh.old/zen.toml";

  # oh-my-posh grava o init script em ~/.cache/oh-my-posh com o caminho
  # absoluto do binário no Nix store. Depois de um rebuild esse path muda
  # e o cache antigo quebra o prompt. Limpar em toda ativação garante que
  # o próximo shell regenere o init.
  home.activation.clearOhMyPoshCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD rm -rf "${config.xdg.cacheHome}/oh-my-posh"
  '';
}
