# =========================================================
# Keybindings
# =========================================================

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# zsh-vi-mode resets all bindings on init
zvm_after_init() {
  # Navegação por palavra
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (sem hidden)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+G -> fzf git branch checkout
  bindkey '^G' _fzf_git_branch

  # Ctrl+\ -> toggle autosuggestions
  bindkey '^\' autosuggest-toggle

  # Ctrl+R -> fzf history
  bindkey '^R' fzf-history-widget

  # Setas -> history substring search
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}
