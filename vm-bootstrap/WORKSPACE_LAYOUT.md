# ClaudeClaw VM Workspace Layout

Status: historical layout draft

Superseded note:

- This layout shows the earlier bootstrap package shape.
- The live hosted owner is `claudeclaw-hosted.service`, not `claudeclaw.service`.
- If `claudeclaw.service` still exists, treat it as dormant and non-canonical.
- For the live hosted owner and rollback rules, use `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`.

## Canonical layout

```text
/opt/claudeclaw/
├── bin/
│   └── start-claudeclaw-vm.sh
├── claudeclaw.env
├── systemd/
│   └── claudeclaw-hosted.service
└── theclaw/
    ├── CLAUDE.md
    ├── .mcp.json
    └── .claude/
        ├── settings.json
        ├── settings.local.json
        ├── statusline.cjs
        └── claudeclaw/
            ├── daemon.pid
            ├── settings.json
            ├── state.json
            ├── session.json
            ├── logs/
            ├── jobs/
            └── prompts/
```

## Ownership model

- Global Claude runtime and plugin cache remain under the operator home:
  - `/home/<operator>/.claude`
  - `/home/<operator>/.claude/plugins`
- Canonical ClaudeClaw project state remains in the workspace:
  - `/opt/claudeclaw/theclaw/.claude/claudeclaw`

## Important separation

- Global Claude config is user-scoped:
  - `/home/<operator>/.claude/settings.json`
- Workspace-specific runtime state is project-scoped:
  - `/opt/claudeclaw/theclaw/.claude/claudeclaw`

## Memory path

Canonical target memory path on the VM:

- MCP server name: `memory`
- MCP provider: Cornerstone
- expected config locations:
  - `/home/<operator>/.claude/settings.json`
  - `/opt/claudeclaw/theclaw/.mcp.json`

Non-canonical memory paths that should stay absent from the final VM runtime:

- `claude-mem`
- `~/.claude-mem`
- `mcp-search`

## Dashboard path

- URL: `http://127.0.0.1:4632/`
- Bind should stay localhost-only for the first VM cutover
