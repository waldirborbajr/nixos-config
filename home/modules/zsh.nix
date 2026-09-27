# home/modules/zsh.nix
#
# Zsh sob controle do Home Manager.
# Conteúdo dos antigos zshenv + ZDOTDIR/{aliases,bindings,functions,fzf,
# plugins,prompt,zoxide}.zsh embutido via envExtra / initContent /
# shellAliases / plugins nativos do HM.
{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    # Absolute path — relative dotDir is deprecated in recent HM
    dotDir = "${config.xdg.configHome}/zsh";

    # ---------- History (antes em zshenv) ----------
    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    # ---------- Aliases (aliases.zsh) ----------
    shellAliases = {
      # Better ls / eza
      ls = "eza --icons";
      ll = "eza -lh --icons --git";
      la = "eza -lah --icons --git";
      tree = "eza --tree --icons";

      # Better cat / grep / diff
      cat = "bat";
      grep = "rg --color=auto";
      diff = "diff --color=auto";
      df = "df -h";

      # Navigation
      "-" = "cd -";

      # Editor
      vim = "nvim";
      emacs = "emacs -nw";

      # Git
      glog = "PAGER=\"less -F -X\" git log";
      gadog = "PAGER=\"less -F -X\" git log --all --decorate --oneline --graph";

      # Utils
      lg = "lazygit";
      yz = "yazi";
      todo = "nvim ~/.todo";
      "?" = "gpt";
      "??" = "duck";
      "???" = "google";
      rmvim = "rm -rf ~/.local/share/nvim ~/.cache/nvim ~/.local/state/nvim";

      # Safety / defaults
      # Nota: o aliases.zsh original redefine `ls` no final. Preferimos eza.
      rm = "rm -I --preserve-root";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      ping = "ping -c 5";

      # Dev
      zsh-time = "for i in $(seq 1 5); do /usr/bin/time zsh -i -c exit; done 2>&1";

      # Zoxide helpers (zoxide.zsh)
      zoxa = "zoxide add";
      zoxq = "zoxide query";
      zoxr = "zoxide remove";
    };

    # ---------- Plugins nativos do HM ----------
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    historySubstringSearch = {
      enable = true;
      searchUpKey = "^[[A";
      searchDownKey = "^[[B";
    };

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
      }
    ];

    # ---------- ~/.zshenv (fora do ZDOTDIR) ----------
    envExtra = ''
      # ---------- XDG base directories ----------
      export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}
      export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
      export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
      export XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}

      # ZDOTDIR — reforça o valor (HM já escreve .zshrc em dotDir)
      export ZDOTDIR=''${ZDOTDIR:-${config.xdg.configHome}/zsh}

      # History dir
      [[ -d "${config.xdg.stateHome}/zsh" ]] || mkdir -p "${config.xdg.stateHome}/zsh"

      # ---------- Pager ----------
      if command -v bat >/dev/null 2>&1; then
        export MANPAGER="bat -l man -p"
      elif command -v batcat >/dev/null 2>&1; then
        export MANPAGER="batcat -l man -p"
      fi

      # ---------- GPG ----------
      [[ -t 0 ]] && export GPG_TTY=$(tty)

      # ---------- Starship ----------
      export STARSHIP_CONFIG="${config.xdg.configHome}/zsh/starship.toml"

      # ---------- PATH ----------
      typeset -U path

      # Home Manager session vars (standalone)
      if [[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Personal binaries/scripts
      export PATH="$HOME/.local/bin:$PATH"

      # Rust
      [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

      # Go
      export PATH="/usr/local/go/bin:$PATH"
      export GOPATH="$HOME/go"
      export PATH=$PATH:$GOPATH/bin

      # Hide computer name in terminal
      export DEFAULT_USER="$(whoami)"

      # DEVBOX
      export PATH="$HOME/.local/devbox/bin:$PATH"
    '';

    # ---------- .zshrc body ----------
    initContent = ''
      # eza completions reuse ls
      if command -v eza >/dev/null 2>&1; then
        compdef eza=ls 2>/dev/null || true
      fi

      # =========================================================
      # prompt.zsh
      # =========================================================
      export VIRTUAL_ENV_DISABLE_PROMPT=1

      # =========================================================
      # fzf.zsh
      # =========================================================
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

      # =========================================================
      # functions.zsh
      # =========================================================
      syshealth() {
        setopt localoptions pipefail no_unset

        echo "🧠 Detecting OS..."

        if command -v nala >/dev/null 2>&1 || command -v apt >/dev/null 2>&1; then
          echo "🐧 Debian/Ubuntu detected"
          if command -v nala >/dev/null 2>&1; then
            PKG="nala"
          else
            PKG="apt"
          fi

          sudo $PKG install -f -y 2>/dev/null
          sudo dpkg --configure -a
          echo "🧹 Cleaning system..."
          sudo rm -rf /var/lib/apt/lists/*
          sudo $PKG update && sudo $PKG upgrade -y
          sudo $PKG autoremove -y
          sudo $PKG clean

        elif command -v dnf >/dev/null 2>&1; then
          echo "🎩 Fedora detected"
          sudo dnf upgrade --refresh -y
          sudo dnf autoremove -y
          sudo dnf clean all

        else
          echo "❌ Unsupported package manager"
          return 1
        fi

        if command -v flatpak >/dev/null 2>&1; then
          echo "📦 Updating Flatpak..."
          flatpak update -y
          flatpak uninstall --unused -y
        fi

        if command -v snap >/dev/null 2>&1; then
          echo "📦 Refreshing Snap packages..."
          sudo snap refresh
        fi

        if command -v go >/dev/null 2>&1; then
          echo "🐹 Updating Go packages (go install)..."
          if command -v gup >/dev/null 2>&1; then
            gup update
          else
            echo " ℹ️  gup not found. Install it once with:"
            echo "    go install github.com/nao1215/gup@latest"
            echo "    Then re-run syshealth to keep all go-install binaries updated."
          fi
        fi

        if command -v rustup >/dev/null 2>&1; then
          echo "🦀 Updating Rust toolchain..."
          rustup update
        fi
        if command -v cargo >/dev/null 2>&1 && command -v cargo-install-update >/dev/null 2>&1; then
          echo "🦀 Updating cargo-installed packages..."
          cargo install-update -a
        fi

        if command -v ya >/dev/null 2>&1; then
          echo "📁 Updating ya packages..."
          ya pkg upgrade
        fi

        echo "🎉 System updated!"
      }

      dockerzap() {
        echo "⚠️ FULL Docker cleanup"

        local containers images

        containers=$(docker ps -aq)
        if [[ -n "$containers" ]]; then
          docker stop $containers
          docker rm $containers
        fi

        images=$(docker images -q)
        if [[ -n "$images" ]]; then
          docker rmi -f $images
        fi

        docker volume prune -f
        docker network prune -f
        docker system prune -a -f --volumes

        echo "🔥 Docker wiped"
      }

      dockernew() {
        echo "⚠️ RESET Docker (DESTRUCTIVE)"

        sudo systemctl stop docker
        sudo rm -rf /var/lib/docker/*
        sudo systemctl start docker

        echo "🔥 Docker reset complete"
      }

      zl() { zellij list-sessions }
      za() { zellij attach "$1" }
      zs() { zellij -s "$1" }
      zc() { rm -rf ~/.cache/zellij }

      tmx() {
        [[ -n "$TMUX" || -n "$SSH_CONNECTION" ]] && return
        tmux attach -t default 2>/dev/null || tmux new -s default
      }

      lzg() { command -v lazygit >/dev/null && lazygit }
      lzq() { command -v lazysql >/dev/null && lazysql }
      lzd() { command -v lazydocker >/dev/null && lazydocker }

      zellij_tab_name_update() {
        [[ -z "''${ZELLIJ:-}" ]] && return

        local name

        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          name=$(basename "$(git rev-parse --show-toplevel)")
        else
          name="''${PWD##*/}"
        fi

        command nohup zellij action rename-tab "$name" >/dev/null 2>&1
      }

      if [[ -n "''${ZELLIJ:-}" ]]; then
        chpwd_functions+=(zellij_tab_name_update)
      fi

      chirp_update() {
        local BASE="https://archive.chirpmyradio.com/chirp_next/"
        local LATEST

        echo "🔍 Checking CHIRP..."

        LATEST=$(curl -fsSL "$BASE" | grep -oE '[0-9]{8}' | sort -nr | head -1)

        if [[ -z "$LATEST" ]]; then
          echo "❌ Failed to fetch version"
          return 1
        fi

        local FILE="chirp-''${LATEST}-py3-none-any.whl"
        local URL="''${BASE}next-''${LATEST}/''${FILE}"

        echo "📦 Latest: $LATEST"

        curl -fLo "$FILE" "$URL" || return 1
        pipx install --force "$FILE" && rm -f "$FILE"

        echo "✅ CHIRP updated"
      }

      update_go() {
        local CURRENT LATEST FILE URL

        if command -v go >/dev/null 2>&1; then
          CURRENT=$(go version | awk '{print $3}' | sed 's/go//')
        fi

        LATEST=$(curl -fsSL https://go.dev/VERSION?m=text | sed 's/go//')

        if [[ -z "$LATEST" ]]; then
          echo "❌ Failed to fetch version"
          return 1
        fi

        echo "📦 Go latest: $LATEST"

        if [[ "$CURRENT" == "$LATEST" ]]; then
          echo "✅ Up to date"
          return 0
        fi

        FILE="go''${LATEST}.linux-amd64.tar.gz"
        URL="https://dl.google.com/go/$FILE"

        curl -fLo "/tmp/$FILE" "$URL" || return 1

        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf "/tmp/$FILE"

        rm -f "/tmp/$FILE"

        echo "🎉 Go updated → $LATEST"
      }

      killf() {
        local pid
        pid=$(ps -ef | sed 1d | fzf | awk '{print $2}') || return
        kill -9 "$pid"
      }

      session() {
        [[ -n "$SSH_CONNECTION" || -n "$TMUX" || -n "$ZELLIJ" ]] && return

        if command -v zellij >/dev/null 2>&1; then
          local s
          s=$(zellij list-sessions 2>/dev/null | head -1)

          if [[ -n "$s" ]]; then
            zellij attach "$s"
          else
            zellij
          fi
          return
        fi

        if command -v tmux >/dev/null 2>&1; then
          tmux attach || tmux new
        else
          echo "❌ No multiplexer found"
        fi
      }

      # Coding cockpit: neovim + claude + terminal in tmux
      nic() {
        local session_name="''${1:-$(basename "$PWD")}"

        if [[ -n "$TMUX" ]]; then
          echo "Already in a tmux session. Detach first or run from outside tmux."
          return 1
        fi

        if tmux has-session -t "$session_name" 2>/dev/null; then
          tmux attach-session -t "$session_name"
          return
        fi

        tmux new-session -d -s "$session_name" -c "$PWD" -x "$(tput cols)" -y "$(tput lines)"
        tmux split-window -v -t "$session_name" -c "$PWD" -l 20%
        tmux split-window -h -t "$session_name":1.1 -c "$PWD" -l 30%
        tmux send-keys -t "$session_name":1.1 'nvim' C-m
        tmux send-keys -t "$session_name":1.2 'claude' C-m
        tmux select-pane -t "$session_name":1.1
        tmux attach-session -t "$session_name"
      }

      # Helix Search
      hxs() {
        RG_PREFIX="rg -i --files-with-matches"
        local files
        files="$(
          FZF_DEFAULT_COMMAND_DEFAULT_COMMAND="$RG_PREFIX '$1'" \
            fzf --multi 3 --print0 --sort --preview="[[ ! -z {} ]] && rg --pretty --ignore-case --context 5 {q} {}" \
              --phony -i -q "$1" \
              --bind "change:reload:$RG_PREFIX {q}" \
              --preview-window="70%:wrap" \
              --bind 'ctrl-a:select-all'
        )"
        [[ "$files" ]] && hx --vsplit $(echo $files | tr \\0 " ")
      }

      # =========================================================
      # bindings.zsh — roda em zvm_after_init (zsh-vi-mode reseta binds)
      # =========================================================
      ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
      ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
      ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

      ZVM_VI_HIGHLIGHT_BACKGROUND=none
      ZVM_VI_HIGHLIGHT_FOREGROUND=none
      ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

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

        # Ctrl+R -> atuin history
        if typeset -f _atuin_search_widget >/dev/null 2>&1; then
          bindkey '^R' _atuin_search_widget
        fi

        # Setas -> history substring search
        bindkey '^[[A' history-substring-search-up
        bindkey '^[[B' history-substring-search-down
      }
    '';
  };

  # ---------- Integrações nativas do HM ----------
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # atuin → home/modules/atuin.nix (programs.atuin + enableZshIntegration)
  # Ctrl+R continua em zvm_after_init via _atuin_search_widget
}
