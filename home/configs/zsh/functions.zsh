# ===========================================
# 🚀 ELITE TROOP - FUNCTIONS (REFINADO)
# ===========================================

#######################################
# System Health
#######################################
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

  # Flatpak
  if command -v flatpak >/dev/null 2>&1; then
    echo "📦 Updating Flatpak..."
    flatpak update -y
    flatpak uninstall --unused -y
  fi

  # Snap
  if command -v snap >/dev/null 2>&1; then
    echo "📦 Refreshing Snap packages..."
    sudo snap refresh
  fi

  # Go binaries installed with `go install`
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

  # Rust / cargo
  if command -v rustup >/dev/null 2>&1; then
    echo "🦀 Updating Rust toolchain..."
    rustup update
  fi
  if command -v cargo >/dev/null 2>&1 && command -v cargo-install-update >/dev/null 2>&1; then
    echo "🦀 Updating cargo-installed packages..."
    cargo install-update -a
  fi

  # ya (yazi package manager)
  if command -v ya >/dev/null 2>&1; then
    echo "📁 Updating ya packages..."
    ya pkg upgrade
  fi

  echo "🎉 System updated!"
}

#######################################
# Docker (SAFE)
#######################################
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

#######################################
# Zellij / Tmux
#######################################
zl() { zellij list-sessions }
za() { zellij attach "$1" }
zs() { zellij -s "$1" }
zc() { rm -rf ~/.cache/zellij }

tmx() {
  [[ -n "$TMUX" || -n "$SSH_CONNECTION" ]] && return
  tmux attach -t default 2>/dev/null || tmux new -s default
}

#######################################
# Lazy tools
#######################################
lzg() { command -v lazygit >/dev/null && lazygit }
lzq() { command -v lazysql >/dev/null && lazysql }
lzd() { command -v lazydocker >/dev/null && lazydocker }

#######################################
# Zellij dynamic tab name
#######################################
zellij_tab_name_update() {
  [[ -z "${ZELLIJ:-}" ]] && return

  local name

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    name=$(basename "$(git rev-parse --show-toplevel)")
  else
    name="${PWD##*/}"
  fi

  command nohup zellij action rename-tab "$name" >/dev/null 2>&1
}

if [[ -n "${ZELLIJ:-}" ]]; then
  chpwd_functions+=(zellij_tab_name_update)
fi

#######################################
# CHIRP updater
#######################################
chirp_update() {
  local BASE="https://archive.chirpmyradio.com/chirp_next/"
  local LATEST

  echo "🔍 Checking CHIRP..."

  LATEST=$(curl -fsSL "$BASE" | grep -oE '[0-9]{8}' | sort -nr | head -1)

  if [[ -z "$LATEST" ]]; then
    echo "❌ Failed to fetch version"
    return 1
  fi

  local FILE="chirp-${LATEST}-py3-none-any.whl"
  local URL="${BASE}next-${LATEST}/${FILE}"

  echo "📦 Latest: $LATEST"

  curl -fLo "$FILE" "$URL" || return 1
  pipx install --force "$FILE" && rm -f "$FILE"

  echo "✅ CHIRP updated"
}

#######################################
# Go updater
#######################################
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

  FILE="go${LATEST}.linux-amd64.tar.gz"
  URL="https://dl.google.com/go/$FILE"

  curl -fLo "/tmp/$FILE" "$URL" || return 1

  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "/tmp/$FILE"

  rm -f "/tmp/$FILE"

  echo "🎉 Go updated → $LATEST"
}

#######################################
# Process killer
#######################################
killf() {
  local pid
  pid=$(ps -ef | sed 1d | fzf | awk '{print $2}') || return
  kill -9 "$pid"
}

#######################################
# Session manager
#######################################
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
  local session_name="${1:-$(basename "$PWD")}"

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
