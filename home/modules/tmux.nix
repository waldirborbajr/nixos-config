# home/modules/tmux.nix
#
# MIGRAÇÃO (nível micro, igual ao tmux.nix do ulyssecrn): antes era
# `programs.tmux.enable` (em cli-and-terminal.nix) + xdg.configFile
# apontando pra home/configs/tmux/tmux.conf. Agora o conteúdo do
# tmux.conf original é embutido ao vivo via programs.tmux.extraConfig +
# builtins.readFile — HM escreve o tmux.conf de verdade a partir disto,
# byte a byte igual ao arquivo antigo (TPM bootstrap, tema Tokyo Night
# Moon hardcoded, binds, tudo preservado).
#
# home/configs/tmux.old/ guarda a pasta original inteira (renomeada, não
# apagada — incluindo tmux.conf.nord, um tema alternativo não usado pelo
# tmux.conf, e o README) — prova de que foi incorporada aqui. Nada mais
# no tmux.conf faz `source-file` de outro arquivo da pasta, então dava
# pra aposentar a pasta inteira (diferente do zsh, onde só o .zshrc
# virou .old — os outros .zsh continuam sendo `source`ados em runtime).
_: let
  configs = ../configs;
in {
  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile "${configs}/tmux.old/tmux.conf";
  };
}
