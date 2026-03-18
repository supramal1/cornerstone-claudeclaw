# ClaudeClaw Hosted Telegram Cutover Runbook

Current classification: `NO-GO, NOT ATTEMPTED`
Last updated: 2026-03-17 ~21:00 (Terminal 5 sprint scan)

Do not execute the cutover sequence below until every blocker in `CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_READINESS_NOTE.md` is cleared.

## Sprint window status (2026-03-17)

- Window authorized: Yes (`CUTOVER_WINDOW_AUTHORIZED.env` present)
- Cutover executed: No
- Blocker `claude-mem:mcp-search`: **RESOLVED**
- Blocker dual ownership: Still present
- Blocker single-owner smoke: Not executed

## Scope

- Stop at Telegram ownership only.
- Do not stop `openclaw-gateway.service`.
- Do not retire legacy services beyond the Telegram handoff itself.
- Do not send real email.

## Pre-cutover gates

All must be true before cutover:

1. `PROVEN`: `claudeclaw-hosted.service` is active and enabled.
2. `PROVEN`: `cornerstone-telegram.service` is active immediately before handoff.
3. `PROVEN`: rollback anchor exists:
   - `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw`
4. `PROVEN`: hosted workspace `claude mcp list` does not show `plugin:claude-mem:mcp-search`.
5. `PROVEN`: hosted Telegram is not already conflicting with the legacy bot, or hosted Telegram has been intentionally disabled until handoff.
6. `PROVEN`: the hosted bot identity and allowlist are the intended cutover target.
7. `PROVEN`: a single-owner Telegram smoke passes after `cornerstone-telegram.service` is stopped.

## Exact forward path once gates are green

### 0. Capture pre-cutover evidence

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status claudeclaw-hosted.service --no-pager

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status cornerstone-telegram.service --no-pager

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status openclaw-gateway.service --no-pager

cd /home/openclaw/claudeclaw/theclaw
sudo -n -u openclaw env HOME=/home/openclaw PATH=/home/openclaw/.bun/bin:/usr/local/bin:/usr/bin:/bin claude mcp list

ls -ld /home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw
```

### 1. Stop legacy Telegram ownership only

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user stop cornerstone-telegram.service
```

### 2. Do not touch the gateway

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status openclaw-gateway.service --no-pager
```

Expected:

- `openclaw-gateway.service` remains `active (running)`

### 3. Verify hosted ClaudeClaw remains healthy

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status claudeclaw-hosted.service --no-pager

curl -fsS http://127.0.0.1:4632/ >/tmp/claudeclaw-cutover-dashboard.html
wc -c /tmp/claudeclaw-cutover-dashboard.html

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  journalctl --user -u claudeclaw-hosted.service -n 120 --no-pager
```

Expected:

- service still `active (running)`
- dashboard still responds on `127.0.0.1:4632`
- no new polling-conflict errors

### 4. Run the Telegram smoke sheet

Use:

- `CLAUDECLAW_HOSTED_TELEGRAM_SMOKE_SHEET.md`

### 5. Decision after smoke

- If smoke passes, keep `openclaw-gateway.service` running for the soak window.
- If smoke fails, execute `CLAUDECLAW_HOSTED_TELEGRAM_ROLLBACK_EXECUTION_SHEET.md` immediately.

## Notes

- This runbook is intentionally more exact than “stop legacy, hope new bot works.”
- The current verdict remains `NO-GO` until the blockers are cleared and a single-owner smoke is proven.
