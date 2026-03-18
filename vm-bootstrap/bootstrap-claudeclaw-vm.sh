#!/usr/bin/env bash
set -euo pipefail

# Draft bootstrap script for a Debian 12 ClaudeClaw VM.
# Intended to be reviewed before use.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

OPERATOR_HOME="${OPERATOR_HOME:-$HOME}"
OPERATOR_USER="${OPERATOR_USER:-$(id -un)}"
CLAUDE_DIR="${CLAUDE_DIR:-$OPERATOR_HOME/.claude}"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-/opt/claudeclaw/theclaw}"
INSTALL_ROOT="${INSTALL_ROOT:-/opt/claudeclaw}"
BIN_DIR="${BIN_DIR:-$INSTALL_ROOT/bin}"
SYSTEMD_DIR="${SYSTEMD_DIR:-$INSTALL_ROOT/systemd}"
ENV_FILE="${ENV_FILE:-$INSTALL_ROOT/claudeclaw.env}"

CORNERSTONE_ROOT="${CORNERSTONE_ROOT:-/opt/cornerstone}"
CORNERSTONE_INTEGRATIONS_ROOT="${CORNERSTONE_INTEGRATIONS_ROOT:-/opt/cornerstone-integrations}"
CORNERSTONE_MCP_PYTHON="${CORNERSTONE_MCP_PYTHON:-$CORNERSTONE_ROOT/.venv/bin/python}"
CORNERSTONE_MCP_SERVER="${CORNERSTONE_MCP_SERVER:-$CORNERSTONE_INTEGRATIONS_ROOT/mcp_server.py}"

DASHBOARD_HOST="${DASHBOARD_HOST:-127.0.0.1}"
DASHBOARD_PORT="${DASHBOARD_PORT:-4632}"

log() {
  printf '[bootstrap] %s\n' "$*"
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" ]]; then
    local stamp
    stamp="$(date +%Y%m%d%H%M%S)"
    cp "$target" "$target.bak.$stamp"
    log "Backed up $target to $target.bak.$stamp"
  fi
}

log "Installing base Debian packages"
sudo apt-get update
sudo apt-get install -y \
  bash \
  ca-certificates \
  curl \
  git \
  jq \
  nodejs \
  npm \
  python3 \
  python3-venv \
  unzip

if ! command -v bun >/dev/null 2>&1; then
  log "Installing Bun"
  curl -fsSL https://bun.sh/install | bash
fi

export PATH="$OPERATOR_HOME/.bun/bin:$PATH"

require_cmd node
require_cmd npm
require_cmd python3
require_cmd jq
require_cmd bun

if ! command -v claude >/dev/null 2>&1; then
  log "Installing Claude Code CLI"
  npm install -g @anthropic-ai/claude-code
fi

require_cmd claude

log "Creating install roots"
sudo mkdir -p "$INSTALL_ROOT" "$BIN_DIR" "$SYSTEMD_DIR"
sudo mkdir -p "$WORKSPACE_ROOT/.claude/claudeclaw/logs"
sudo mkdir -p "$WORKSPACE_ROOT/.claude/claudeclaw/jobs"
sudo mkdir -p "$WORKSPACE_ROOT/.claude/claudeclaw/prompts"
sudo chown -R "$(id -u)":"$(id -g)" "$INSTALL_ROOT"

mkdir -p "$CLAUDE_DIR"

log "Writing env file"
backup_if_exists "$ENV_FILE"
cat > "$ENV_FILE" <<EOF
CLAUDECLAW_WORKSPACE=$WORKSPACE_ROOT
CLAUDECLAW_DASHBOARD_HOST=$DASHBOARD_HOST
CLAUDECLAW_DASHBOARD_PORT=$DASHBOARD_PORT
CORNERSTONE_ROOT=$CORNERSTONE_ROOT
CORNERSTONE_INTEGRATIONS_ROOT=$CORNERSTONE_INTEGRATIONS_ROOT
CORNERSTONE_MCP_PYTHON=$CORNERSTONE_MCP_PYTHON
CORNERSTONE_MCP_SERVER=$CORNERSTONE_MCP_SERVER
EOF

log "Installing Linux-valid Claude settings template"
backup_if_exists "$CLAUDE_DIR/settings.json"
cat > "$CLAUDE_DIR/settings.json" <<EOF
{
  "enabledPlugins": {
    "claudeclaw@claudeclaw": true
  },
  "mcpServers": {
    "memory": {
      "command": "$CORNERSTONE_MCP_PYTHON",
      "args": [
        "$CORNERSTONE_MCP_SERVER"
      ]
    }
  }
}
EOF

log "Installing Linux-valid workspace MCP template"
backup_if_exists "$WORKSPACE_ROOT/.mcp.json"
cat > "$WORKSPACE_ROOT/.mcp.json" <<EOF
{
  "mcpServers": {
    "memory": {
      "command": "$CORNERSTONE_MCP_PYTHON",
      "args": [
        "$CORNERSTONE_MCP_SERVER"
      ]
    }
  }
}
EOF

if [[ ! -f "$WORKSPACE_ROOT/CLAUDE.md" ]]; then
  log "Creating placeholder CLAUDE.md"
  cat > "$WORKSPACE_ROOT/CLAUDE.md" <<'EOF'
# ClaudeClaw VM Workspace

Replace this placeholder with the canonical project CLAUDE.md before first production start.
EOF
fi

log "Installing ClaudeClaw plugin"
claude plugin marketplace add moazbuilds/claudeclaw || true
claude plugin install claudeclaw

log "Installing launcher wrapper"
install -m 0755 "$SCRIPT_DIR/start-claudeclaw-vm.sh" "$BIN_DIR/start-claudeclaw-vm.sh"

log "Installing systemd unit draft"
backup_if_exists "$SYSTEMD_DIR/claudeclaw-hosted.service"
sed \
  -e "s#__OPERATOR_USER__#$OPERATOR_USER#g" \
  -e "s#__INSTALL_ROOT__#$INSTALL_ROOT#g" \
  -e "s#__WORKSPACE_ROOT__#$WORKSPACE_ROOT#g" \
  "$SCRIPT_DIR/templates/claudeclaw-hosted.service.template" > "$SYSTEMD_DIR/claudeclaw-hosted.service"

log "Bootstrap draft complete"
log "Next manual step: run 'claude' once as this operator to complete authentication"
log "Then validate Cornerstone MCP paths:"
log "  $CORNERSTONE_MCP_PYTHON"
log "  $CORNERSTONE_MCP_SERVER"
log "Do not enable the systemd unit until parity checks are complete"
