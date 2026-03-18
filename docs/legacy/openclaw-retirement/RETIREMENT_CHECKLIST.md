# OpenClaw Retirement Checklist

## Purpose

This checklist is the operator pack for retiring the remaining OpenClaw-era hosted path after hosted ClaudeClaw cutover and soak both pass.

Retirement does not begin until all of the following are true:

- `claudeclaw-hosted.service` is healthy on the VM
- Cornerstone MCP is the only accepted hosted memory path
- Telegram ownership has moved to ClaudeClaw successfully
- the hosted soak window has completed
- rollback artifacts are frozen and readable
- any dormant `claudeclaw.service` path is confirmed non-canonical

## Dependency Map

| Artifact | Proven path or name | Current role | Classification | Retirement note |
|---|---|---|---|---|
| Hosted legacy gateway unit | `/home/openclaw/.config/systemd/user/openclaw-gateway.service` | Starts the legacy OpenClaw gateway on port `18789` via `/usr/lib/node_modules/openclaw/dist/index.js gateway --port 18789` | keep until cutover | Stop only after Telegram cutover has succeeded and the hosted soak window is complete |
| Hosted legacy Telegram unit | `/home/openclaw/.config/systemd/user/cornerstone-telegram.service` | Runs the legacy Python Telegram bot with `%h/cornerstone/.venv/bin/python main.py telegram` | keep until cutover | First hosted legacy service to stop once ClaudeClaw Telegram ownership is proven |
| Hosted Telegram failure helper | `/home/openclaw/.config/systemd/user/cornerstone-telegram-notify.service` | `OnFailure` helper for `cornerstone-telegram.service` | archive later | Archive or remove with the legacy Telegram unit after rollback closes |
| Hosted OpenClaw package | `/usr/lib/node_modules/openclaw` | Runtime code used by `openclaw-gateway.service` | preserve for rollback | Leave installed through soak; remove only after rollback window closes |
| Hosted OpenClaw state | `/home/openclaw/.openclaw` | Legacy config, cron state, and scripts path used by OpenClaw-era flows | preserve for rollback | Keep intact for service rollback and forensic comparison until final cleanup window |
| Hosted rollback anchor | `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw` | Canonical pre-cutover snapshot | preserve for rollback | Must remain unchanged until the rollback window is explicitly closed |
| Hosted stale MCP config reference | `/home/openclaw/cornerstone-integrations/.claude/mcp.json` | Previously discovered MCP config that pointed at Mac paths | archive later | Keep only as historical evidence once the canonical ClaudeClaw VM config is proven |
| Ops reference copy of gateway unit | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/openclaw-gateway.service` | Repo copy of the VM user unit | archive later | Retain as historical ops reference or move to a `legacy/` area after rollback closes |
| Ops reference copy of Telegram unit | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/cornerstone-telegram.service` | Repo copy of the VM user unit | archive later | Retain as historical ops reference or move to a `legacy/` area after rollback closes |
| Telegram health script | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/tgcheck.sh` | Health check for `cornerstone-telegram.service`, Proton Bridge, and `.openclaw/cron/jobs.json` | archive later | No longer canonical once Telegram is ClaudeClaw-owned and OpenClaw cron is gone |
| OpenClaw source repo | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw` | Legacy runtime source, memory scripts, hooks, workspace bootstrap | archive later | Preserve read-only after cutover; archive after rollback window if no consumer remains |
| OpenClaw memory scripts | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw/scripts/save_memory.py` and `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw/scripts/post_session_extract.py` | Supabase-era memory writers tagged as `openclaw` / `openclaw_session` | archive later | Not part of the ClaudeClaw + Cornerstone canonical path |
| OpenClaw session hook | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw/hooks/supabase-extract/HOOK.md` | Legacy `/new` `/reset` `/stop` extraction hook targeting `~/.openclaw/scripts/post_session_extract.py` | archive later | Preserve only as legacy implementation reference |
| OpenClaw workspace bootstrap and skill | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw/workspace/BOOTSTRAP.md` and `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw/workspace/skills/memory/SKILL.md` | Assumes OpenClaw bootstrap and `~/.openclaw/scripts/*.py` memory flows | archive later | Not valid for the ClaudeClaw canonical workspace |
| AionUI OpenClaw bridge scripts and docs | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui-openclaw.sh`, `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui_openclaw_acp_bridge.py`, `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/AIONUI_OPENCLAW.md` | Desktop-specific OpenClaw routing and bridge docs | archive later | Local OpenClaw is already non-canonical; keep only if a desktop rollback use-case is still desired |
| ClaudeClaw migration docs | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CLAUDECLAW_CANONICAL_MIGRATION.md` and `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SPRINT_BOARD.md` | Canonical cutover evidence and gate tracking | preserve for rollback | Keep as the operator record of the cutover and soak decision |

## Retirement Gates

- [ ] PROVEN `claudeclaw-hosted.service` is healthy under `systemd`
- [ ] PROVEN ClaudeClaw owns Telegram successfully
- [ ] PROVEN Cornerstone MCP is the only accepted hosted memory path
- [ ] PROVEN no canonical hosted capability still depends on `openclaw-gateway.service`
- [ ] PROVEN rollback anchor `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw` is still present
- [ ] PROVEN preserved copies of the two legacy user units are readable
- [ ] PROVEN hosted soak window has completed without needing legacy fallback
- [ ] PROVEN any dormant `claudeclaw.service` path is documented as stale and unused
- [ ] OPERATOR SIGN-OFF recorded for retirement start

## Cutover-Day Freeze

- [ ] Capture final pre-stop status for `claudeclaw-hosted.service`, `openclaw-gateway.service`, and `cornerstone-telegram.service`
- [ ] Capture final proof that ClaudeClaw dashboard is healthy on `127.0.0.1:4632`
- [ ] Capture final proof that `claude mcp list` in the hosted ClaudeClaw workspace exposes Cornerstone and no legacy memory path
- [ ] Confirm `/home/openclaw/.openclaw` has not been modified by ad hoc rollback testing
- [ ] Confirm the rollback snapshot path remains unchanged
- [ ] Confirm `cornerstone-telegram.service` is still the live legacy Telegram owner immediately before handoff

## Immediate Post-Cutover Tasks

- [ ] Stop `cornerstone-telegram.service` only after ClaudeClaw Telegram ownership passes live proof
- [ ] Leave `openclaw-gateway.service` running during the initial post-cutover soak
- [ ] Record any Telegram-side regressions before touching the gateway service

## Post-Soak Retirement Tasks

- [ ] Stop `openclaw-gateway.service`
- [ ] Preserve the legacy package, unit definitions, and `.openclaw` state for rollback
- [ ] Move repo-local OpenClaw docs and scripts to a clearly marked legacy or archive location
- [ ] Update canonical docs so OpenClaw is described only as retired legacy
- [ ] Close the rollback window explicitly before any permanent deletion step

## What Remains After OpenClaw Retirement

These items remain canonical even after OpenClaw retirement:

- ClaudeClaw hosted ownership docs under `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`
- ClaudeClaw VM bootstrap artifacts under `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/vm-bootstrap`
- Cornerstone MCP server code and integrations under `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations`
- non-OpenClaw Cornerstone infrastructure such as `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/proton-bridge/proton-bridge.service`, if still needed by separate Cornerstone workflows
- hosted ClaudeClaw workspace and service artifacts
- operator migration and cutover records needed for audit and rollback history
