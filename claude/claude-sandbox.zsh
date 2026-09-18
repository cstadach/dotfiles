# dotfiles/claude/claude-sandbox.zsh
# Auto-sourced by holman dotfiles (topic/*.zsh convention)
# Runs Claude Code in a sandboxed Docker container with per-project memory.
# A long-lived Claude Pro/Max token (from `claude setup-token`) is stored in
# 1Password and injected via CLAUDE_CODE_OAUTH_TOKEN so normal runs skip the
# browser login entirely. Optionally bridges to a running claudecode.nvim
# WebSocket server.
#
# Requirements:
#   Docker Desktop running
#   brew install 1password-cli socat jq   (socat/jq optional, for Neovim bridge)
#
# Usage:
#   claude-sandbox [--build] [--login] [--help] [claude flags]
#
# Per-project .claude/ is created in the current directory (conversation
# memory only — auth no longer lives here). Add .claude/ to your project's
# .gitignore. -r/--resume is prepended by default on normal runs.

claude-sandbox() {
  local IMAGE_NAME="claude-sandbox"
  local OP_ITEM="Anthropic"
  local OP_VAULT="Private"
  local OP_TOKEN_REF="op://${OP_VAULT}/${OP_ITEM}/credential"

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

  _cs_login() {
    _cs_check || return 1
    if ! command -v op &>/dev/null; then
      echo "${RED}[sandbox]${NC} 1Password CLI not found — brew install 1password-cli" >&2
      return 1
    fi
    if ! docker image inspect "$IMAGE_NAME" &>/dev/null 2>&1; then
      _cs_build
    fi

    echo "${BLUE}[sandbox]${NC} Starting Claude Pro/Max login (claude setup-token)..."
    echo "${YELLOW}[sandbox]${NC} Follow the link, authorize in the browser, then copy the token it prints."
    echo ""
    docker run -it --rm \
      --hostname claude-sandbox \
      --cap-drop ALL \
      -e TERM=xterm-256color \
      "${IMAGE_NAME}" \
      setup-token

    echo ""
    local token
    read -rs "token?Paste the token printed above: "
    echo ""
    if [[ -z "$token" ]]; then
      echo "${RED}[sandbox]${NC} No token entered — aborting." >&2
      return 1
    fi

    if op item edit "$OP_ITEM" --vault "$OP_VAULT" "credential=${token}" &>/dev/null \
      || op item create --category "API Credential" --title "$OP_ITEM" --vault "$OP_VAULT" "credential=${token}" &>/dev/null; then
      echo "${GREEN}[sandbox]${NC} Token saved to 1Password (${OP_TOKEN_REF})."
    else
      echo "${RED}[sandbox]${NC} Failed to save token to 1Password." >&2
      return 1
    fi
  }

  _cs_build() {
    echo "${BLUE}[sandbox]${NC} Building image..."
    local ctx
    ctx=$(mktemp -d)

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
    git curl ca-certificates ripgrep bash socat jq openssh-client \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
EOF

    docker build --no-cache -t "$IMAGE_NAME" "$ctx" || {
      rm -rf "$ctx"
      echo "${RED}[sandbox]${NC} Image build failed." >&2
      return 1
    }
    rm -rf "$ctx"
    echo "${GREEN}[sandbox]${NC} Image ready."
  }

  _cs_run() {
    local project_dir="${PWD}"
    local claude_dir="${project_dir}/.claude"
    mkdir -p "$claude_dir/ide"
    [[ -s "${claude_dir}/claude.json" ]] || echo '{}' > "${claude_dir}/claude.json"

    echo "${BLUE}[sandbox]${NC} Project : ${project_dir}"
    echo "${YELLOW}[sandbox]${NC} Isolated: only ${project_dir} is mounted (no home dir, no SSH keys)."

    local oauth_token=""
    if command -v op &>/dev/null; then
      oauth_token=$(op read "$OP_TOKEN_REF" 2>/dev/null)
    fi
    if [[ -z "$oauth_token" ]]; then
      echo "${YELLOW}[sandbox]${NC} No saved token — running login first."
      _cs_login || return 1
      oauth_token=$(op read "$OP_TOKEN_REF" 2>/dev/null)
    fi
    local -a auth_args=()
    if [[ -n "$oauth_token" ]]; then
      auth_args=(-e "CLAUDE_CODE_OAUTH_TOKEN=${oauth_token}")
      echo "${GREEN}[sandbox]${NC} Auth    : token loaded from 1Password"
    fi
    echo ""

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
          cat > "$relay_lock" <<LOCKEOF
{"pid":${nvim_pid},"workspaceFolders":["${project_dir}"],"ideName":"Neovim","transport":"ws","authToken":"${auth_token}"}
LOCKEOF
          socat TCP-LISTEN:${relay_port},bind=0.0.0.0,reuseaddr,fork \
                TCP:127.0.0.1:${ws_port} &>/dev/null &
          socat_pid=$!
          echo "${BLUE}[sandbox]${NC} Neovim bridge: WS port ${ws_port} → relay ${relay_port}"
        fi
      fi
    fi

    docker run -it --rm \
      --hostname claude-sandbox \
      --add-host host.docker.internal:host-gateway \
      -v "${project_dir}:${project_dir}" \
      -v "${claude_dir}:/root/.claude" \
      -v "${claude_dir}/claude.json:/root/.claude.json" \
      --cap-drop ALL \
      -e TERM=xterm-256color \
      "${auth_args[@]}" \
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
    --login)
      _cs_login
      ;;
    --help|-h)
      echo "Usage: claude-sandbox [--build] [--login] [--help] [claude flags]"
      echo ""
      echo "  (no args)   Run Claude Code sandboxed in the current directory"
      echo "              (-r/--resume is prepended automatically)"
      echo "  --build     Rebuild the Docker image"
      echo "  --login     Generate a long-lived Pro/Max token, save it to 1Password"
      echo ""
      echo "Auth is loaded automatically from 1Password (${OP_TOKEN_REF})."
      echo "If no token is saved yet, --login runs automatically on first use."
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
      _cs_run -r "$@"
      ;;
  esac
}
