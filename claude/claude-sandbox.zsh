# dotfiles/claude/claude-sandbox.zsh
# Auto-sourced by holman dotfiles (topic/*.zsh convention)
# Runs Claude Code in a sandboxed Docker container.
# API key is fetched from 1Password at runtime — never stored in plaintext.
#
# Setup:
#   1. brew install 1password-cli
#   2. Enable: 1Password app → Settings → Developer → Integrate with 1Password CLI
#   3. Save your Anthropic API key in 1Password as an item named "Anthropic"
#      with a field named "api-key" (or adjust OP_SECRET_REF below)
#   4. Run: claude-sandbox

# 1Password secret reference — adjust vault/item/field to match yours
# Find it in 1Password: right-click field → Copy Secret Reference
OP_ANTHROPIC_REF="op://Private/Anthropic/credential"

claude-sandbox() {
  local IMAGE_NAME="claude-sandbox"
  local WORK_DIR="/workspace"

  local BLUE='\033[0;34m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local RED='\033[0;31m'
  local NC='\033[0m'

  _claude_sandbox_check() {
    if ! command -v docker &>/dev/null; then
      echo -e "${RED}[sandbox]${NC} Docker not found — brew install --cask docker"
      return 1
    fi
    if ! docker info &>/dev/null 2>&1; then
      echo -e "${RED}[sandbox]${NC} Docker not running — start Docker Desktop."
      return 1
    fi
    if ! command -v op &>/dev/null; then
      echo -e "${RED}[sandbox]${NC} 1Password CLI not found — brew install 1password-cli"
      return 1
    fi
    if ! op account list &>/dev/null 2>&1; then
      echo -e "${RED}[sandbox]${NC} Not signed in to 1Password — run: op signin"
      return 1
    fi
  }

  _claude_sandbox_fetch_key() {
    echo -e "${BLUE}[sandbox]${NC} Fetching API key from 1Password (Touch ID)..."
    local key
    key=$(op read "$OP_ANTHROPIC_REF" 2>/dev/null)
    if [[ -z "$key" ]]; then
      echo -e "${RED}[sandbox]${NC} Could not read key from 1Password."
      echo -e "         Check that the secret reference is correct: ${OP_ANTHROPIC_REF}"
      echo -e "         Or update OP_ANTHROPIC_REF in dotfiles/claude/claude-sandbox.zsh"
      return 1
    fi
    echo "$key"
  }

  _claude_sandbox_build() {
    echo -e "${BLUE}[sandbox]${NC} Building image (once)..."
    docker build --quiet -t "$IMAGE_NAME" - <<'DOCKERFILE'
FROM node:20-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g @anthropic-ai/claude-code

RUN useradd -m -u 1000 claude
USER claude
WORKDIR /workspace

ENTRYPOINT ["claude"]
DOCKERFILE
    echo -e "${GREEN}[sandbox]${NC} Image ready."
  }

  _claude_sandbox_run() {
    local api_key="$1"
    shift

    echo -e "${BLUE}[sandbox]${NC} Project : ${PWD}"
    echo -e "${YELLOW}[sandbox]${NC} Mounted : ${PWD} only — no home dir, no SSH keys, no env vars."
    echo ""

    docker run -it --rm \
      -v "${PWD}:${WORK_DIR}" \
      --network host \
      --cap-drop ALL \
      --cap-add NET_BIND_SERVICE \
      --security-opt no-new-privs \
      -e ANTHROPIC_API_KEY="${api_key}" \
      -e TERM=xterm-256color \
      -w "${WORK_DIR}" \
      "${IMAGE_NAME}" \
      "$@"
  }

  case "${1:-}" in
    --build)
      _claude_sandbox_check || return 1
      _claude_sandbox_build
      ;;
    --help|-h)
      echo "Usage: claude-sandbox [--build] [--help] [claude flags]"
      echo ""
      echo "  (no args)   Fetch API key from 1Password, run Claude in sandbox"
      echo "  --build     Force rebuild the Docker image"
      echo "  --help      Show this help"
      echo ""
      echo "  1Password ref: ${OP_ANTHROPIC_REF}"
      echo "  Update OP_ANTHROPIC_REF in dotfiles/claude/claude-sandbox.zsh to match your vault."
      ;;
    *)
      _claude_sandbox_check || return 1
      if ! docker image inspect "$IMAGE_NAME" &>/dev/null 2>&1; then
        _claude_sandbox_build
      fi
      local api_key
      api_key=$(_claude_sandbox_fetch_key) || return 1
      _claude_sandbox_run "$api_key" "$@"
      ;;
  esac
}
