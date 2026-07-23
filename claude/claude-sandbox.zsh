# dotfiles/claude/claude-sandbox.zsh
# Auto-sourced by holman dotfiles (topic/*.zsh convention)
# Runs Claude Code in a sandboxed Docker container with per-project memory.
# Optionally bridges to a running claudecode.nvim WebSocket server.
#
# Requirements:
#   Docker Desktop running
#   brew install socat jq   (optional, for Neovim bridge)
#
# Usage:
#   claude-sandbox [--build] [--help] [claude flags]
#
# Per-project .claude/ is created in the current directory.
# Add .claude/ to your project's .gitignore.

claude-sandbox() {
  local IMAGE_NAME="claude-sandbox"

  local BLUE='\033[0;34m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local RED='\033[0;31m'
  local NC='\033[0m'

  _cs_check() {
    if ! command -v docker &>/dev/null; then
      echo "${RED}[sandbox]${NC} Docker not found — brew install --cask docker" >&2
      return 1
    fi
    if ! docker info &>/dev/null 2>&1; then
      echo "${RED}[sandbox]${NC} Docker not running — start Docker Desktop." >&2
      return 1
    fi
  }

  _cs_build() {
    echo "${BLUE}[sandbox]${NC} Building image..."
    local ctx
    ctx=$(mktemp -d)

    # Entrypoint: set up Neovim IDE bridge, then run claude.
    # The bridge connects container 127.0.0.1:RELAY_PORT to the host socat
    # which relays to claudecode.nvim's WebSocket server.
    cat > "$ctx/entrypoint.sh" <<'EOF'
#!/bin/bash
set -e

# Set up in-container socat bridge so Claude CLI can reach the Neovim
# WebSocket server on the host via the relay set up by claude-sandbox.
LOCK_FILE=$(ls -t /root/.claude/ide/*.lock 2>/dev/null | head -1)
if [[ -n "$LOCK_FILE" ]]; then
  RELAY_PORT=$(basename "$LOCK_FILE" .lock)
  socat TCP-LISTEN:${RELAY_PORT},bind=127.0.0.1,reuseaddr,fork \
        TCP:host.docker.internal:${RELAY_PORT} &>/dev/null &
fi

exec claude "$@"
EOF

    cat > "$ctx/Dockerfile" <<'EOF'
FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ripgrep bash socat jq \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
EOF

    docker build --quiet -t "$IMAGE_NAME" "$ctx"
    rm -rf "$ctx"
    echo "${GREEN}[sandbox]${NC} Image ready."
  }

  _cs_run() {
    local project_dir="${PWD}"
    local claude_dir="${project_dir}/.claude"
    mkdir -p "$claude_dir/ide"

    echo "${BLUE}[sandbox]${NC} Project : ${project_dir}"
    echo "${YELLOW}[sandbox]${NC} Isolated: only ${project_dir} is mounted (no home dir, no SSH keys)."
    echo ""

    # --- Neovim IDE bridge (optional) ---
    # Requires: socat + jq on the host, claudecode.nvim active in Neovim.
    # Architecture (Mac — no --network host):
    #   Claude CLI (container) → 127.0.0.1:RELAY
    #     → container socat (entrypoint.sh) → host.docker.internal:RELAY
    #     → host socat (below) → 127.0.0.1:WS_PORT
    #     → claudecode.nvim WebSocket server
    local socat_pid="" relay_lock=""
    if command -v socat &>/dev/null && command -v jq &>/dev/null; then
      local lock_file ws_port nvim_pid auth_token relay_port
      lock_file=$(ls -t "$HOME/.claude/ide/"*.lock 2>/dev/null | head -1)
      if [[ -n "$lock_file" ]]; then
        ws_port=$(basename "$lock_file" .lock)
        nvim_pid=$(jq -r '.pid' "$lock_file" 2>/dev/null)
        auth_token=$(jq -r '.authToken' "$lock_file" 2>/dev/null)
        if [[ -n "$auth_token" && "$auth_token" != "null" ]]; then
          relay_port=$((ws_port + 10000))
          relay_lock="${claude_dir}/ide/${relay_port}.lock"

          # Write bridge lock file into the per-project .claude/ide/ so the
          # CLI inside the container discovers it at /root/.claude/ide/
          cat > "$relay_lock" <<LOCKEOF
{"pid":${nvim_pid},"workspaceFolders":["${project_dir}"],"ideName":"Neovim","transport":"ws","authToken":"${auth_token}"}
LOCKEOF

          # Host-side relay: accept container connections, forward to Neovim WS
          socat TCP-LISTEN:${relay_port},bind=0.0.0.0,reuseaddr,fork \
                TCP:127.0.0.1:${ws_port} &>/dev/null &
          socat_pid=$!

          echo "${BLUE}[sandbox]${NC} Neovim bridge: WS port ${ws_port} → relay ${relay_port}"
        fi
      fi
    fi

    docker run -it --rm \
      --add-host host.docker.internal:host-gateway \
      -v "${project_dir}:${project_dir}" \
      -v "${claude_dir}:/root/.claude" \
      --cap-drop ALL \
      -e TERM=xterm-256color \
      -w "${project_dir}" \
      "${IMAGE_NAME}" \
      "$@"
    local rc=$?

    [[ -n "$socat_pid" ]] && kill "$socat_pid" 2>/dev/null
    [[ -n "$relay_lock" ]] && rm -f "$relay_lock"
    return $rc
  }

  case "${1:-}" in
    --build)
      _cs_check || return 1
      _cs_build
      ;;
    --help|-h)
      echo "Usage: claude-sandbox [--build] [--help] [claude flags]"
      echo ""
      echo "  (no args)   Run Claude Code sandboxed in the current directory"
      echo "  --build     Rebuild the Docker image"
      echo ""
      echo "Per-project memory is stored in .claude/ in the current directory."
      echo "Add .claude/ to your project's .gitignore."
      echo ""
      echo "Neovim IDE bridge activates automatically when claudecode.nvim is"
      echo "running and socat + jq are installed (brew install socat jq)."
      ;;
    *)
      _cs_check || return 1
      if ! docker image inspect "$IMAGE_NAME" &>/dev/null 2>&1; then
        _cs_build
      fi
      _cs_run "$@"
      ;;
  esac
}
