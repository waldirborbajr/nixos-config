# Better ls
alias ls='eza --icons'

# Detailed listing
alias ll='eza -lh --icons --git'

# Detailed listing including hidden files
alias la='eza -lah --icons --git'

# Tree view
alias tree='eza --tree --icons'

# Reuse ls completions for eza (avoids defining a separate completion function)
compdef eza=ls

# Better cat
alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

alias -- -='cd -'  # -- prevents - being parsed as a flag; cd - jumps to previous directory

# =========================================================
# Editor
# =========================================================

alias vim='nvim'

# =========================================================
# Git
# =========================================================

alias glog='PAGER="less -F -X" git log'                              # -F quit if one screen, -X no clear on exit
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'

# #######################################
# # 🚀 ELITE TROOP - ALIASES + FZF + GIT
# #######################################

# #######################################
# # Editor
# #######################################
# alias vim="nvim"
# alias nv="nvim"
# alias edit="nvim $ZDOTDIR/.zshrc"

# #######################################
# # Shell / Config
# #######################################
# alias reload="exec zsh"

# #######################################
# # Navigation
# #######################################
# alias ..="cd .."
# alias ...="cd ../.."
# alias ....="cd ../../.."

# # fzf navigation
# cdf() {
#   cd "$(fd --type d | fzf)"
# }

# vf() {
#   nvim "$(fd --type f | fzf)"
# }

# #######################################
# # Modern ls (eza)
# #######################################
# alias ls="eza --icons --group-directories-first"
# alias ll="eza -lg --icons --group-directories-first"
# alias la="eza -lag --icons --group-directories-first"

# #######################################
# # CLI improvements
# #######################################
# alias grep="grep --color=auto"
# alias diff="diff --color=auto"
# alias ip="ip -c"

# #######################################
# # Filesystem utils
# #######################################
# alias tree="tree -a"
# alias free="free -h"
# alias df="df -h"
# alias chmodx="chmod +x"

# #######################################
# # Modern replacements
# #######################################
# alias cat="bat"
# alias find="fd"

# #######################################
# # Git base
# #######################################
# alias g="git"
# alias ga="git add"
# alias gap="git add --patch"

# alias gb="git branch"
# alias gba="git branch --all"

# alias gc="git commit"
# alias gca="git commit --amend --no-edit"
# alias gce="git commit --amend"

# alias gco="git checkout"
# alias gsw="git switch"
# alias gn="git checkout -b"

# alias gcl="git clone --recursive"

# alias gd="git diff"
# alias gds="git diff --staged"

# alias gi="git init"

# alias gl="git log --graph --decorate --all --oneline"
# alias gll="git log --pretty=format:'%C(magenta)%h %C(white)%an %ar%C(auto) %D%n%s%n'"

# alias gm="git merge"
# alias gp="git push"
# alias gu="git pull"

# alias gr="git reset"
# alias gs="git status --short"

# alias ghc="gh repo create --private --source=. --remote=origin && git push -u --all && gh browse"

# #######################################
# # 🔥 GIT + FZF (ABSURDO)
# #######################################

# gcof() {
#   local branch
#   branch=$(git branch --all | sed 's/.* //' | sort -u | fzf --height 40% --reverse) || return
#   git checkout "${branch#remotes/origin/}"
# }

# gcor() {
#   git for-each-ref --sort=-committerdate refs/heads/ \
#     --format='%(refname:short)' | fzf | xargs git checkout
# }

# gcf() {
#   local commit
#   commit=$(git log --oneline --color=always | fzf \
#     --ansi \
#     --preview 'git show --color=always {1}' \
#     --height 80%) || return
#   echo $commit | awk '{print $1}' | xargs git checkout
# }

# gdf() {
#   git diff --name-only | fzf \
#     --preview 'git diff --color=always {}' \
#     --height 80% | xargs git diff
# }

# gaf() {
#   git status --short | fzf -m \
#     --preview 'git diff --color=always {2}' \
#     | awk '{print $2}' | xargs git add
# }

# grf() {
#   git status --short | fzf -m \
#     | awk '{print $2}' | xargs git restore
# }

# gstf() {
#   git stash list | fzf \
#     --preview 'git stash show -p --color=always {1}' \
#     | awk -F: '{print $1}' | xargs git stash apply
# }

# gbdf() {
#   git branch | fzf | xargs git branch -D
# }

# #######################################
# # 🔍 Search (fzf + rg)
# #######################################

# rgf() {
#   local file
#   file=$(rg --line-number --no-heading --color=always "" | \
#     fzf --ansi \
#         --delimiter : \
#         --preview 'bat --color=always {1} --highlight-line {2}' \
#         --height 80%) || return

#   nvim "$(echo $file | cut -d: -f1)"
# }

# #######################################
# # 🐳 Docker
# #######################################
# alias dc="docker compose"
# alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
# alias dl="docker logs --tail=100"

# dkill() {
#   docker ps --format "{{.Names}}" | fzf | xargs docker kill
# }

# dlogf() {
#   docker ps --format "{{.Names}}" | fzf | xargs docker logs -f
# }

# #######################################
# # 🧠 Processes
# #######################################
# killf() {
#   ps -ef | fzf | awk '{print $2}' | xargs kill -9
# }

# #######################################
# # Dotfiles
# #######################################
# alias dotfiles="/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
# alias d="/usr/bin/git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"
# alias dot="cd ~/dotfiles"

# #######################################
# # Git repos shortcuts
# #######################################
# alias git-notes="git -C ~/notes"
# alias git-when="git -C ~/.when"
# alias git-ledger="git -C ~/.ledger"

# alias sync-commit-notes="git-notes add --all && git-notes commit -m sync && git-notes pull && git-notes push"

# alias cj-pull="pass git pull; git-notes pull; git-when pull; git-ledger pull"
# alias cj-status="pass git status; git-notes status; git-when status; git-ledger status"

# #######################################
# # Tmux
# #######################################
# alias tmux="tmux -f ~/.config/tmux/tmux.conf"
# alias ta="tmux attach"
# alias tl="tmux list-sessions"
# alias tn="tmux new-session -s"
# alias ses="sh $XDG_CONFIG_HOME/tmux/tmux-sessionizer.sh"

# #######################################
# # Ripgrep
# #######################################
# alias rg="rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim \
# --colors=line:fg:black --colors=line:style:bold \
# --colors=path:fg:magenta --colors=match:style=nobold"

# #######################################
# # System
# #######################################
# alias reboot="systemctl reboot"
# alias shutdown="sudo shutdown now"
# alias restart="sudo reboot"
# alias suspend="sudo pm-suspend"

# alias syslist="systemctl list-units --type=service --state=running"

alias rmvim="rm -rf ~/.local/share/nvim ~/.cache/nvim ~/.local/state/nvim"

# #######################################
# # Utils
# #######################################
alias lg="lazygit"
alias yz="yazi"

# alias c="clear"
# alias e="exit"

# #######################################
# # Paths
# #######################################
# alias prj="cd ~/prj"

# #######################################
# # Misc
# #######################################
alias todo="nvim ~/.todo"
alias '?'="gpt"
alias '??'="duck"
alias '???'="google"

alias ls='ls -lah --color=always --group-directories-first'
alias rm=' rm -I --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ping='ping -c 5'

# =========================================================
# Dev utilities
# =========================================================

# Mede o tempo de startup do zsh (5 amostras)
alias zsh-time='for i in $(seq 1 5); do /usr/bin/time zsh -i -c exit; done 2>&1'
