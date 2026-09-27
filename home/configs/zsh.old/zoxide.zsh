# =========================================================
# Zoxide — navegação inteligente de diretórios (substitui/complementa cd)
# https://github.com/ajeetdsouza/zoxide
# =========================================================
#
# `zoxide init zsh` gera as funções `z` e `zi` e registra o hook que
# aprende os diretórios visitados. O banco de dados fica em
# $XDG_DATA_HOME/zoxide/db.zo (já garantido por zshenv).
#
# Uso básico:
#   z <termo>     -> pula pro diretório mais "frequente/recente" que casa
#                     com o termo (ex.: `z dotfiles`)
#   z             -> sem argumento, comporta-se como `cd ~`
#   z -           -> diretório anterior (equivalente ao `cd -`)
#   zi <termo>    -> abre um seletor interativo (usa fzf, se disponível)
#                     quando há mais de um resultado ambíguo
#
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
else
  echo "zsh: zoxide não encontrado no PATH — pulando inicialização." >&2
fi

# Atalhos curtos de navegação (prefixo "zox" pra não colidir com os
# atalhos do zellij em functions.zsh: zl, za, zs, zc)
alias zoxa='zoxide add'      # adiciona o diretório atual manualmente ao banco
alias zoxq='zoxide query'    # consulta sem entrar no diretório
alias zoxr='zoxide remove'   # remove uma entrada do banco
