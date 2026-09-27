# home/shell.nix
#
# ZDOTDIR layout do zsh, direnv e capacidades do terminal.
#
# zoxide / eza / fzf: binários partilhados por todos os hosts via HM.
# A init do zoxide continua em home/configs/zsh/zoxide.zsh (não usar
# programs.zoxide.enable para não duplicar o eval).
#
# EDITOR/VISUAL não ficam mais fixos aqui — vêm de home/editors.nix,
# calculados dinamicamente a partir de qual editor está ligado.
#
# MIGRAÇÃO (nível micro, igual ao shell.nix do ulyssecrn): o .zshrc
# antigo virou config nativa — ${configs}/zsh/.zshrc.old (renomeado, não
# apagado) tem o conteúdo original completo, agora embutido em
# programs.zsh.initContent via builtins.readFile. Os OUTROS arquivos
# (.zsh) continuam linkados como estavam: o .zshrc embutido faz `source
# "$ZDOTDIR/aliases.zsh"` etc, então esses arquivos precisam continuar
# existindo em $ZDOTDIR — não dá pra "aposentar" a pasta inteira, só o
# arquivo de entrada.
{pkgs, ...}: let
  configs = ../configs;
in {
  # .zshenv must live outside ZDOTDIR.
  home.file.".zshenv".source = "${configs}/zshenv";

  # ZDOTDIR contents — tudo MENOS .zshrc (agora nativo via initContent
  # abaixo). O diretório fonte já não tem mais um arquivo ".zshrc" (foi
  # renomeado pra ".zshrc.old"), então não há colisão com o .zshrc que o
  # home-manager gera a partir de initContent.
  xdg.configFile."zsh" = {
    source = "${configs}/zsh";
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;

    # Conteúdo original do .zshrc, embutido ao vivo — HM escreve o
    # $ZDOTDIR/.zshrc de verdade a partir disto, byte a byte igual ao
    # arquivo antigo (mesma história/ordem de source dos módulos .zsh).
    initContent = builtins.readFile "${configs}/zsh/.zshrc.old";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  # Navegação / listagem / fuzzy — usados pelos dotfiles em configs/zsh/
  home.packages = with pkgs; [
    zoxide
    eza
    fzf
  ];

  # Suporte a cor de 24-bit no terminal — usado por qualquer coisa no
  # shell (fzf, bat, delta, prompts), não é específico de nenhum editor.
  home.sessionVariables.COLORTERM = "truecolor";
}
