# modules/apps/zsh.nix
{ config, pkgs, lib, ... }:

let
  gitPrompt = pkgs.writeShellScriptBin "git-prompt" ''
    #!/usr/bin/env bash
    set -euo pipefail

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then exit 0; fi

    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || true)"
    [ -n "''${branch:-}" ] || exit 0

    st="$(git status --porcelain=v1 2>/dev/null || true)"

    dirty=""
    staged=""
    untracked=""

    if echo "$st" | grep -qE '^[ MARC?DU][MD] '; then staged="+"; fi
    if echo "$st" | grep -qE '^[MDARC?DU][ MD] '; then dirty="*"; fi
    if echo "$st" | grep -qE '^\?\? '; then untracked="?"; fi

    ahead=""
    behind=""
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
      counts="$(git rev-list --left-right --count HEAD...@{u} 2>/dev/null || true)"
      left="''${counts%% *}"
      right="''${counts##* }"
      if [ "''${left:-0}" != "0" ]; then ahead="⇡"; fi
      if [ "''${right:-0}" != "0" ]; then behind="⇣"; fi
    fi

    printf "%s%s%s%s%s" "$branch" "$staged" "$dirty" "$untracked" "$ahead$behind"
  '';
in
{
  programs.zsh = {
    enable = true;

    # Aqui definimos o comportamento do histórico via setopt (o que realmente funciona no NixOS)
    shellInit = ''
      # Histórico: tamanho grande, ignore dups, share entre sessões, etc.
      setopt appendhistory sharehistory hist_ignore_space hist_ignore_all_dups hist_save_no_dups hist_ignore_dups hist_find_no_dups
      HISTSIZE=10000
      SAVEHIST=10000
      HISTFILE=~/.zsh_history   # padrão, mas explícito
    '';

    shellAliases = {
      c   = "clear";
      q   = "exit";
      ll  = "eza -lg --icons --group-directories-first";
      la  = "eza -lag --icons --group-directories-first";
      rg  = "rg --hidden --smart-case --glob='!.git/' --no-search-zip --trim";

      gs  = "git status --short";
      ga  = "git add";
      gc  = "git commit";
      gp  = "git push";
      gu  = "git pull";
      gd  = "git diff";
      gds = "git diff --staged";

      runfree = ''"$@" >/dev/null 2>&1 & disown'';
    };

    interactiveShellInit = ''
      # Vi mode
      bindkey -v
      bindkey "^[[A" history-beginning-search-backward   # up
      bindkey "^[[B" history-beginning-search-forward    # down

      # Completion
      autoload -Uz compinit && compinit -C
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*' menu no

      # bat como pager/manpager
      if command -v bat >/dev/null 2>&1; then
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        export PAGER=bat
      fi

      # FZF
      if command -v fzf >/dev/null 2>&1; then
        export FZF_DEFAULT_OPTS="--info=inline-right --ansi --layout=reverse --border=rounded"
      fi

      # zoxide
      if command -v zoxide >/dev/null 2>&1; then
        eval "$(zoxide init --cmd cd zsh)"
      fi

      # Prompt minimalista + git
      git_seg() {
        local s
        s="$(${gitPrompt}/bin/git-prompt 2>/dev/null)"
        [ -n "$s" ] && echo " %F{magenta}$s%f"
      }

      precmd() {
        local code=$?
        local sym
        if [ $code -eq 0 ]; then
          sym="%F{green}❯%f"
        else
          sym="%F{red}❯%f"
        fi
        PROMPT="%F{cyan}%~%f$(git_seg)\n$sym "
      }
    '';
  };

  environment.systemPackages = with pkgs; [
    git fzf zoxide eza bat ripgrep
  ];

  environment.sessionVariables = {
    EDITOR       = "nvim";
    VISUAL       = "nvim";
    SUDO_EDITOR  = "nvim";
    BROWSER      = "com.brave.Browser";
    TERMINAL     = "kitty";
    NPM_CONFIG_UPDATE_NOTIFIER = "false";
    NPM_CONFIG_FUND            = "false";
    NPM_CONFIG_AUDIT           = "false";
    PYTHONDONTWRITEBYTECODE    = "1";
    PIP_DISABLE_PIP_VERSION_CHECK = "1";
  };
}
