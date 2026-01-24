{ config, pkgs, lib, ... }:

let
  zshrc = ''
    # =========================================================
    # ZSH (Nix-managed) - minimal DevOps prompt
    # - No zinit / no powerlevel10k
    # - Fast prompt: cwd + git branch + dirty
    # =========================================================

    # XDG
    export ZDOTDIR="$HOME/.config/zsh"
    export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
    mkdir -p "$ZSH_CACHE_DIR"

    # ---------------------------------------------------------
    # Basic options
    # ---------------------------------------------------------
    setopt autocd
    setopt correct
    setopt interactivecomments
    setopt magicequalsubst
    setopt nonomatch
    setopt notify
    setopt numericglobsort
    setopt promptsubst
    setopt appendhistory
    setopt sharehistory
    setopt hist_ignore_space
    setopt hist_ignore_all_dups
    setopt hist_save_no_dups
    setopt hist_ignore_dups
    setopt hist_find_no_dups

    # History
    HISTSIZE=10000
    SAVEHIST=$HISTSIZE
    HISTFILE="$HOME/.zsh_history"

    # ---------------------------------------------------------
    # Environment
    # ---------------------------------------------------------
    export EDITOR="nvim"
    export VISUAL="nvim"
    export SUDO_EDITOR="nvim"
    export FCEDIT="nvim"

    # Keep your browser/terminal vars if you want (optional)
    export BROWSER="com.brave.Browser"

    if command -v bat >/dev/null 2>&1; then
      export MANPAGER="sh -c 'col -bx | bat -l man -p'"
      export PAGER="bat"
    fi

    # ---------------------------------------------------------
    # Keybindings (vi-mode)
    # ---------------------------------------------------------
    bindkey -v
    bindkey "^[[A" history-beginning-search-backward
    bindkey "^[[B" history-beginning-search-forward

    # ---------------------------------------------------------
    # Completion styling
    # ---------------------------------------------------------
    zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu no

    # ---------------------------------------------------------
    # PATH helpers (safe)
    # ---------------------------------------------------------
    pathappend() {
      for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
          PATH="${PATH:+"$PATH:"}$ARG"
        fi
      done
    }

    pathprepend() {
      for ARG in "$@"; do
        if [ -d "$ARG" ] && [[ ":$PATH:" != *":$ARG:"* ]]; then
          PATH="$ARG${PATH:+":$PATH"}"
        fi
      done
    }

    pathprepend "$HOME/bin" "$HOME/sbin" "$HOME/.local/bin" "$HOME/local/bin" "$HOME/.bin"
    pathappend "$HOME/.cargo/bin" "$HOME/go/bin" "$HOME/.tmuxifier/bin"

    # ---------------------------------------------------------
    # Aliases / Functions (split files, Nix-managed)
    # ---------------------------------------------------------
    source "$ZDOTDIR/aliases.zsh"
    source "$ZDOTDIR/functions.zsh"

    # ---------------------------------------------------------
    # zoxide / tmuxifier (keep your workflow)
    # ---------------------------------------------------------
    if command -v zoxide >/dev/null 2>&1; then
      eval "$(zoxide init --cmd cd zsh)"
    fi

    if command -v tmuxifier >/dev/null 2>&1; then
      eval "$(tmuxifier init -)"
    fi

    # ---------------------------------------------------------
    # Prompt: cwd + git branch + dirty (FAST)
    # ---------------------------------------------------------
    autoload -Uz vcs_info

    # Only Git (fast)
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' formats ' %b'
    zstyle ':vcs_info:git:*' actionformats ' %b|%a'

    # Quick dirty check (no remote, no fetch)
    _git_dirty() {
      command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
      # --untracked-files=no avoids expensive scans
      command git status --porcelain --untracked-files=no 2>/dev/null | command grep -q . && echo '*'
      return 0
    }

    precmd() {
      vcs_info
    }

    # Colors
    autoload -Uz colors && colors

    # Left prompt:
    # 1) cwd
    # 2) ❯ with git branch + dirty marker
    PROMPT='%F{blue}%~%f%F{magenta}${vcs_info_msg_0_}%f%F{yellow}$(_git_dirty)%f
%F{green}❯%f '

    # Right prompt (optional): last exit status
    RPROMPT='%(?..%F{red}%?%f)'

    # ---------------------------------------------------------
    # Performance: avoid implicit git fetches from tools
    # ---------------------------------------------------------
    # Don’t auto-fetch in background.
    # Keep this here; it’s cheap and reduces surprise.
    git config --global fetch.auto 0 >/dev/null 2>&1 || true

  '';

  aliases = ''
    # Navigation
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # Safer defaults
    alias c='clear'
    alias e='exit'
    alias mkdir='mkdir -pv'
    alias cp='cp -iv'
    alias mv='mv -iv'
    alias rm='rm -iv'

    # Modern tools (use if installed)
    if command -v eza >/dev/null 2>&1; then
      alias ll="eza -lg --icons --group-directories-first"
      alias la="eza -lag --icons --group-directories-first"
      alias ls="eza -h --icons --group-directories-first"
    else
      alias ls='ls --color=auto'
      alias ll='ls -larth'
    fi

    # Git (short + fast)
    alias ga='git add'
    alias gc='git commit'
    alias gco='git checkout'
    alias gd='git diff'
    alias gds='git diff --staged'
    alias gl='git log --oneline --decorate --graph --all'
    alias gp='git push'
    alias gu='git pull'
    alias gs='git status -sb'
  '';

  functions = ''
    # Start a program detached
    runfree() {
      "$@" > /dev/null 2>&1 & disown
    }

    # yazi wrapper to cd on exit
    y() {
      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
      yazi "$@" --cwd-file="$tmp"
      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        builtin cd -- "$cwd"
      fi
      rm -f -- "$tmp"
    }

    # Session manager (prefer zellij, fallback tmux)
    session() {
      if [[ -n "$SSH_CONNECTION" ]] || [[ -n "$TMUX" ]] || [[ -n "$ZELLIJ" ]]; then
        return 0
      fi

      if command -v zellij >/dev/null 2>&1; then
        if zellij list-sessions 2>/dev/null | grep -q .; then
          zellij attach "$(zellij list-sessions | head -1)"
        else
          zellij
        fi
      elif command -v tmux >/dev/null 2>&1; then
        tmux attach || tmux new
      fi
    }
  '';
in
{
  programs.zsh.enable = true;

  # Nice-to-have Zsh goodies via Nix (no plugin manager)
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;

  environment.systemPackages = with pkgs; [
    zsh
    git
  ];

  # Canonical config in /etc/xdg
  environment.etc."xdg/zsh/.zshrc".text = zshrc;
  environment.etc."xdg/zsh/aliases.zsh".text = aliases;
  environment.etc."xdg/zsh/functions.zsh".text = functions;

  # Symlink to user config (no home-manager)
  systemd.user.services."zsh-xdg-links" = {
    description = "Symlink Zsh configs from /etc/xdg to ~/.config/zsh and ~/.zshrc";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -euo pipefail

      mkdir -p "$HOME/.config/zsh"

      # Main files
      ln -sf /etc/xdg/zsh/.zshrc "$HOME/.config/zsh/.zshrc"
      ln -sf /etc/xdg/zsh/aliases.zsh "$HOME/.config/zsh/aliases.zsh"
      ln -sf /etc/xdg/zsh/functions.zsh "$HOME/.config/zsh/functions.zsh"

      # Ensure ~/.zshrc points to XDG config
      cat > "$HOME/.zshrc" <<'EOF'
export ZDOTDIR="$HOME/.config/zsh"
source "$ZDOTDIR/.zshrc"
EOF
    '';
  };
}