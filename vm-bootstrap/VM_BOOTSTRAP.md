# ClaudeClaw VM Bootstrap

Status: historical bootstrap runbook

Superseded note:

- This file documents the draft first-install path.
- The current canonical hosted unit name is `claudeclaw-hosted.service`.
- Any remaining references here to `claudeclaw.service` are historical bootstrap naming, not current hosted truth.
- Manual hosted `nohup` is rollback-only after service ownership promotion.
- For live hosted ownership and rollback rules, use `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`.

## Goal

Stand up the canonical always-on ClaudeClaw runtime on a Debian 12 VM without relying on OpenClaw, nginx, webhooks, or external cron.

This bootstrap uses the actual ClaudeClaw runtime shape already proven locally:

- `claude` CLI does the model/runtime work
- ClaudeClaw runs as a Bun plugin/runtime
- state lives in the workspace under `.claude/claudeclaw`
- Cornerstone is injected through MCP server `memory`
- Telegram is owned by ClaudeClaw itself
- dashboard stays local-only on `127.0.0.1:4632`

## Canonical Linux paths

- Operator home: `/home/<operator>`
- Claude config root: `/home/<operator>/.claude`
- Claude global settings: `/home/<operator>/.claude/settings.json`
- Workspace root: `/opt/claudeclaw/theclaw`
- Workspace MCP file: `/opt/claudeclaw/theclaw/.mcp.json`
- ClaudeClaw state root: `/opt/claudeclaw/theclaw/.claude/claudeclaw`
- ClaudeClaw logs: `/opt/claudeclaw/theclaw/.claude/claudeclaw/logs`
- ClaudeClaw jobs: `/opt/claudeclaw/theclaw/.claude/claudeclaw/jobs`
- Cornerstone repo: `/opt/cornerstone`
- Cornerstone integrations repo: `/opt/cornerstone-integrations`
- Cornerstone MCP python: `/opt/cornerstone/.venv/bin/python`
- Cornerstone MCP server script: `/opt/cornerstone-integrations/mcp_server.py`

## Minimum runtime stack

1. `node` and `npm`
2. `claude` CLI
3. `bun`
4. `python3` and `python3-venv` for Cornerstone MCP
5. `git`, `curl`, `jq`, `ca-certificates`, `unzip`
6. ClaudeClaw plugin installed into the operator's `~/.claude/plugins`
7. Linux-valid MCP config for Cornerstone
8. Workspace with `CLAUDE.md`, `.mcp.json`, and `.claude/claudeclaw/`

`node` remains required even if ClaudeClaw is started with Bun:

- Claude Code install path is Node/NPM-based per Anthropic quickstart
- ClaudeClaw writes `node .claude/statusline.cjs`
- ClaudeClaw setup docs explicitly check for both Bun and Node

## Bootstrap sequence

### 1. Stage the package on the VM

Copy this `vm-bootstrap/` directory to the VM first. Example destination:

```bash
/tmp/claudeclaw-vm-bootstrap
```

### 2. Review and edit the env template

Edit:

```bash
/tmp/claudeclaw-vm-bootstrap/templates/claudeclaw.env.template
```

Set the final paths if they differ from the defaults:

- `CLAUDECLAW_WORKSPACE`
- `CLAUDECLAW_DASHBOARD_HOST`
- `CLAUDECLAW_DASHBOARD_PORT`
- `CORNERSTONE_ROOT`
- `CORNERSTONE_INTEGRATIONS_ROOT`
- `CORNERSTONE_MCP_PYTHON`
- `CORNERSTONE_MCP_SERVER`

### 3. Run the draft bootstrap script

Run as the intended long-lived operator account, not root:

```bash
cd /tmp/claudeclaw-vm-bootstrap
bash ./bootstrap-claudeclaw-vm.sh
```

What it is designed to do:

- install VM package dependencies
- install Bun
- install Claude Code CLI
- create `/opt/claudeclaw/theclaw`
- create workspace-local `.claude/claudeclaw/{logs,jobs,prompts}`
- install ClaudeClaw plugin
- write Linux-valid `~/.claude/settings.json`
- write Linux-valid workspace `.mcp.json`
- install the `start-claudeclaw-vm.sh` wrapper
- install a systemd unit draft without enabling it

### 4. Manual Claude authentication

Claude authentication is still manual and must happen on the VM under the same operator account that will run ClaudeClaw:

```bash
claude
```

Complete the interactive login flow.

Manual because:

- Claude Code requires account authentication on first use
- auth material is user-scoped
- the bootstrap package should not embed tokens or pre-seed opaque credentials

### 5. Validate MCP paths before first start

Confirm these Linux paths exist on the VM:

```bash
ls -l /opt/cornerstone/.venv/bin/python
ls -l /opt/cornerstone-integrations/mcp_server.py
```

If Cornerstone lives elsewhere, update:

- `/home/<operator>/.claude/settings.json`
- `/opt/claudeclaw/theclaw/.mcp.json`
- `/opt/claudeclaw/claudeclaw.env`

### 6. First runtime start

The intended start path is the wrapper:

```bash
/opt/claudeclaw/bin/start-claudeclaw-vm.sh
```

That wrapper resolves the currently installed ClaudeClaw plugin path dynamically from:

```bash
/home/<operator>/.claude/plugins/installed_plugins.json
```

It then runs:

```bash
bun run <resolved-plugin-root>/src/index.ts start --web
```

from the canonical workspace root.

### 7. Service enablement later

The package includes:

```bash
templates/claudeclaw-hosted.service.template
```

This is for the later cutover step when ClaudeClaw becomes the VM's always-on runtime.

It should not be enabled until:

- Claude CLI auth is complete
- Cornerstone MCP paths are valid
- Telegram bot config is ready
- OpenClaw parity is proven

## What stays manual

- Claude login/auth
- copying real `CLAUDE.md` content to the VM workspace if needed
- confirming the correct Telegram token and allowlist
- confirming final Cornerstone Linux paths
- final `systemctl enable --now ...` when you are ready to cut over

## Not part of this plan

- nginx
- inbound Telegram webhooks
- FastAPI connector layer
- external cron
- `claude-mem`
- OpenClaw reuse beyond parity validation
