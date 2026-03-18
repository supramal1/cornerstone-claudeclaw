# ClaudeClaw Hosted Telegram Cutover Readiness Note

Last live scan: 2026-03-17 (Terminal 5 sprint scan ~21:00)
Previous live scan: 2026-03-17

## Final verdict

`NO-GO, NOT ATTEMPTED`

## PROVEN current live truth

- `PROVEN`: Hosted ClaudeClaw is running under `claudeclaw-hosted.service`.
- `PROVEN`: Legacy Telegram is still running under `cornerstone-telegram.service`.
- `PROVEN`: Legacy gateway is still running under `openclaw-gateway.service`.
- `PROVEN`: Hosted ClaudeClaw runtime settings contain Telegram configuration in:
  - `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
- `PROVEN`: Hosted ClaudeClaw service journal shows:
  - `Telegram: enabled`
  - `Telegram bot started (long polling)`
  - `Bot: @open_claudebot`
- `PROVEN`: Hosted workspace `claude mcp list` still shows:
  - `plugin:claude-mem:mcp-search ... ✓ Connected`
  - `memory ... ✓ Connected`
  - `context7 ... ✓ Connected`
  - `proton-email ... ✓ Connected`
- `PROVEN`: Rollback anchor exists:
  - `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw`

## NOT PROVEN

- `NOT PROVEN`: That hosted ClaudeClaw can be the sole Telegram owner without the legacy bot still running.
- `NOT PROVEN`: That hosted Telegram receive/send behavior is healthy after `cornerstone-telegram.service` is stopped.
- `NOT PROVEN`: That the active Telegram token/identity in hosted ClaudeClaw is the intended final production bot for cutover.
- ~~`NOT PROVEN`: That the canonical hosted memory path is clean of `claude-mem` and `mcp-search`.~~ **RESOLVED** (per HOSTED_OPERATOR_START_HERE.md 20:30)

## Sprint window result (2026-03-17 ~21:00)

- **Classification**: `NO-GO, NOT ATTEMPTED`
- **CUTOVER_ABORT**: Not present
- **Cutover executed**: No
- **Sprint artifacts created**: None (no CUTOVER_PREFLIGHT_VERDICT.md, CUTOVER_EXECUTION_LOG.md, CUTOVER_SMOKE_RESULT.md)
- **Blockers resolved since last scan**: `claude-mem:mcp-search` removed from hosted workspace
- **Blockers remaining**: Dual Telegram ownership, single-owner smoke not proven

## INFERRED

- `INFERRED`: Cutting over Telegram right now would be unsafe because hosted ClaudeClaw is already long-polling while the legacy Telegram service remains live.
- `INFERRED`: The smallest honest blocker set is now narrower than before, but still material.

## Smallest honest blocker list

1. `PROVEN blocker`: hosted ClaudeClaw is already running Telegram long polling while `cornerstone-telegram.service` remains live.
2. `PROVEN blocker`: hosted workspace still exposes `plugin:claude-mem:mcp-search` in `claude mcp list`.
3. `NOT PROVEN blocker`: no live single-owner Telegram smoke proof exists with the legacy bot stopped and rollback preserved.

## Expected artifacts missing at scan time

- `PROVEN`: These cutover-pack files were not present at scan time and were created in this pass:
  - `CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_READINESS_NOTE.md`
  - `CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_RUNBOOK.md`
  - `CLAUDECLAW_HOSTED_TELEGRAM_SMOKE_SHEET.md`
  - `CLAUDECLAW_HOSTED_TELEGRAM_ROLLBACK_EXECUTION_SHEET.md`
  - `NEXT_CUTOVER_VERDICT.md`

## Exact proof commands used

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show claudeclaw-hosted.service -p ActiveState -p SubState -p UnitFileState -p MainPID -p FragmentPath

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show cornerstone-telegram.service -p ActiveState -p SubState -p UnitFileState -p MainPID -p FragmentPath

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show openclaw-gateway.service -p ActiveState -p SubState -p UnitFileState -p MainPID -p FragmentPath

sudo -n -u openclaw python3 - <<'PY'
import json
obj=json.load(open('/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json'))
print('telegram_present', 'telegram' in obj)
print('allowed_ids_count', len(obj.get('telegram',{}).get('allowedUserIds',[])))
print('token_present', bool(obj.get('telegram',{}).get('token')))
PY

cd /home/openclaw/claudeclaw/theclaw
sudo -n -u openclaw env HOME=/home/openclaw PATH=/home/openclaw/.bun/bin:/usr/local/bin:/usr/bin:/bin claude mcp list

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  journalctl --user -u claudeclaw-hosted.service -n 80 --no-pager

ls -ld /home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw
```

## Key outputs

- `ActiveState=active`
- `SubState=running`
- `UnitFileState=enabled`
- `telegram_present True`
- `allowed_ids_count 1`
- `token_present True`
- `Telegram: enabled`
- `Telegram bot started (long polling)`
- `plugin:claude-mem:mcp-search ... ✓ Connected`
- `memory ... ✓ Connected`
