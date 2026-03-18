# ClaudeClaw VM Bootstrap Package

Status: historical bootstrap package

Superseded note:

- This package reflects the earlier bootstrap phase before the hosted owner was standardized.
- The current canonical hosted service name is `claudeclaw-hosted.service`, not `claudeclaw.service`.
- If a dormant `claudeclaw.service` draft unit still exists, do not treat it as canonical.
- Manual hosted `nohup` start is rollback-only after service ownership promotion.
- For the live hosted runbook, use `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`.

This package prepares a Debian/Linux VM for the canonical ClaudeClaw runtime model:

- `claude` CLI
- `bun`
- `node`
- ClaudeClaw plugin install
- workspace-local ClaudeClaw state
- Cornerstone MCP as the only intended memory backend
- localhost-only dashboard on `127.0.0.1:4632`

This package does not touch the live VM by itself. It is a staging bundle to copy to the VM and run later.

## Files

- `VM_BOOTSTRAP.md` — operator runbook for first install
- `DEPENDENCY_CHECKLIST.md` — minimum required VM components
- `WORKSPACE_LAYOUT.md` — canonical Linux paths and state layout
- `bootstrap-claudeclaw-vm.sh` — draft install/bootstrap script
- `start-claudeclaw-vm.sh` — runtime wrapper that resolves the installed plugin path
- `templates/claude-settings.json.template` — global `~/.claude/settings.json` template
- `templates/workspace.mcp.json.template` — workspace `.mcp.json` template
- `templates/claudeclaw.env.template` — operator-editable path/env template
- `templates/claudeclaw-hosted.service.template` — systemd unit draft for the always-on runtime

## Canonical runtime model

- Workspace root: `/opt/claudeclaw/theclaw`
- ClaudeClaw runtime state: `/opt/claudeclaw/theclaw/.claude/claudeclaw`
- Claude global config: `/home/<operator>/.claude/settings.json`
- ClaudeClaw plugin code: `/home/<operator>/.claude/plugins/cache/claudeclaw/...`
- Dashboard bind: `127.0.0.1:4632`
- Cornerstone MCP name: `memory`

## Explicit non-goals

- No nginx
- No Telegram webhooks
- No external cron
- No `claude-mem`
- No OpenClaw integration

## Notes

- The bootstrap script is intentionally conservative and assumes it is run by the long-lived operator account on the VM.
- Claude authentication is still manual. See `VM_BOOTSTRAP.md`.
