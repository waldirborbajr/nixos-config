# =========================================================
# fzf
# =========================================================

# Usa fd se disponível (ou fdfind no Fedora), senão find nativo
if command -v fd &>/dev/null; then
  _FZF_FIND_CMD='fd --type f --hidden'
elif command -v fdfind &>/dev/null; then
  _FZF_FIND_CMD='fdfind --type f --hidden'
else
  _FZF_FIND_CMD='find . -type f'
fi

export FZF_DEFAULT_COMMAND="$_FZF_FIND_CMD"
export FZF_CTRL_T_COMMAND="$_FZF_FIND_CMD"
unset _FZF_FIND_CMD

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Registra fzf-history-widget e demais widgets.
# DEVE rodar antes de plugins.zsh carregar o zsh-vi-mode.
if command -v fzf &>/dev/null; then
  if fzf --zsh &>/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  else
    for _fzf_kb in \
      /usr/share/fzf/key-bindings.zsh \
      /usr/share/doc/fzf/examples/key-bindings.zsh \
      /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
      /usr/local/opt/fzf/shell/key-bindings.zsh; do
      [[ -f "$_fzf_kb" ]] && { source "$_fzf_kb"; break; }
    done
    for _fzf_comp in \
      /usr/share/fzf/completion.zsh \
      /usr/share/doc/fzf/examples/completion.zsh \
      /opt/homebrew/opt/fzf/shell/completion.zsh \
      /usr/local/opt/fzf/shell/completion.zsh; do
      [[ -f "$_fzf_comp" ]] && { source "$_fzf_comp"; break; }
    done
    unset _fzf_kb _fzf_comp
  fi
fi

# Ctrl+F: file picker excluindo hidden files
_fzf_file_no_hidden() {
  local find_cmd result
  if command -v fd &>/dev/null; then
    find_cmd='fd --type f'
  elif command -v fdfind &>/dev/null; then
    find_cmd='fdfind --type f'
  else
    find_cmd='find . -type f -not -path "*/\.*"'
  fi
  result=$(eval "$find_cmd" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# Ctrl+G: checkout de branch git com preview
_fzf_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || { zle reset-prompt; return; }
  local branch
  branch=$(git branch --all 2>/dev/null \
    | grep -v HEAD \
    | sed 's/.* //' | sed 's#remotes/origin/##' \
    | sort -u \
    | fzf --height 40% --reverse \
          --preview 'git log --oneline --color=always {1} 2>/dev/null | head -20') \
    || { zle reset-prompt; return; }
  LBUFFER="git checkout $branch"
  zle accept-line
}
zle -N _fzf_git_branch
