#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_ROOT="${CLAUDECLAW_WORKSPACE:-/opt/claudeclaw/theclaw}"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
INSTALLED_PLUGINS_JSON="${INSTALLED_PLUGINS_JSON:-$CLAUDE_DIR/plugins/installed_plugins.json}"
DASHBOARD_HOST="${CLAUDECLAW_DASHBOARD_HOST:-127.0.0.1}"
DASHBOARD_PORT="${CLAUDECLAW_DASHBOARD_PORT:-4632}"

if [[ ! -f "$INSTALLED_PLUGINS_JSON" ]]; then
  printf 'missing installed plugin metadata: %s\n' "$INSTALLED_PLUGINS_JSON" >&2
  exit 1
fi

PLUGIN_ROOT="$(
  jq -r '
    .plugins["claudeclaw@claudeclaw"][0].installPath // empty
  ' "$INSTALLED_PLUGINS_JSON"
)"

if [[ -z "$PLUGIN_ROOT" || ! -f "$PLUGIN_ROOT/src/index.ts" ]]; then
  printf 'unable to resolve ClaudeClaw plugin root from %s\n' "$INSTALLED_PLUGINS_JSON" >&2
  exit 1
fi

cd "$WORKSPACE_ROOT"
exec bun run "$PLUGIN_ROOT/src/index.ts" start --web --web-port "$DASHBOARD_PORT"
