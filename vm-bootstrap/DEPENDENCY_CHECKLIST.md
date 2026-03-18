# VM Dependency Checklist

## Required packages and runtimes

- `bash`
- `curl`
- `git`
- `jq`
- `ca-certificates`
- `unzip`
- `node`
- `npm`
- `bun`
- `python3`
- `python3-venv`

## Required Claude/ClaudeClaw components

- `claude` CLI installed and on `PATH`
- Claude login completed for the operator account
- ClaudeClaw plugin installed
- `claudeclaw@claudeclaw` enabled in `/home/<operator>/.claude/settings.json`
- Cornerstone MCP configured as `mcpServers.memory`
- workspace `.mcp.json` present at `/opt/claudeclaw/theclaw/.mcp.json`

## Required paths

- `/opt/claudeclaw/theclaw`
- `/opt/claudeclaw/theclaw/.claude/claudeclaw/logs`
- `/opt/claudeclaw/theclaw/.claude/claudeclaw/jobs`
- `/home/<operator>/.claude`
- `/opt/cornerstone/.venv/bin/python`
- `/opt/cornerstone-integrations/mcp_server.py`

## Required runtime behavior

- ClaudeClaw starts from the workspace root, not from `/root` or a temp dir
- Dashboard binds only to `127.0.0.1:4632`
- Runtime state is workspace-local under `.claude/claudeclaw`
- No `claude-mem` plugin enabled for the canonical VM workspace
- No OpenClaw service dependency for ClaudeClaw startup

## Nice-to-have but not strictly required for first bootstrap

- `systemd` unit installed for later enablement
- `tmux` or `screen` for manual first-start observation
