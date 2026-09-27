# home/modules/ripgrep.nix
#
# MIGRAÇÃO (mesmo padrão de shell.nix/btop.nix/tmux.nix): o binário
# `ripgrep` em si segue vindo de system/modules/dev.nix (ferramenta de
# desenvolvimento, disponível em todo host); aqui só a config do
# usuário. Antes era xdg.configFile apontando pra
# home/configs/ripgrep/rgrc. Agora é config nativa via
# programs.ripgrep.arbitraryOptions.
#
# home/configs/ripgrep.old/ guarda o original (renomeado, não apagado).
_: {
  programs.ripgrep = {
    enable = true;
    arbitraryOptions = [
      "--smart-case"
      "--fixed-strings"
    ];
  };
}
