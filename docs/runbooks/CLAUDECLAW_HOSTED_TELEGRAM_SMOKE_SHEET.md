# ClaudeClaw Hosted Telegram Smoke Sheet

Use this only after `cornerstone-telegram.service` has been stopped for a controlled cutover test.

Current readiness classification: `NO-GO, NOT ATTEMPTED`
Last updated: 2026-03-17 ~21:00 (Terminal 5 sprint scan)

## Sprint window status

- Smoke executed: No
- Reason: Cutover not attempted; dual Telegram ownership blocker not resolved

## Preconditions

- `PROVEN`: `claudeclaw-hosted.service` is active
- `PROVEN`: `openclaw-gateway.service` is still active
- `PROVEN`: rollback anchor exists
- `PROVEN`: hosted workspace `claude mcp list` is clean of `plugin:claude-mem:mcp-search`
- `PROVEN`: hosted Telegram bot identity is the intended production target

## Smoke steps

### 1. Service health

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status claudeclaw-hosted.service --no-pager

curl -fsS http://127.0.0.1:4632/ >/tmp/claudeclaw-smoke-dashboard.html
wc -c /tmp/claudeclaw-smoke-dashboard.html
```

Pass condition:

- `claudeclaw-hosted.service` still `active (running)`
- dashboard still responds

### 2. Journal sanity

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  journalctl --user -u claudeclaw-hosted.service -n 150 --no-pager
```

Pass condition:

- no polling conflict
- no crash loop
- no permission-mode or MCP-startup failure introduced by the handoff

### 3. Human Telegram smoke

Perform manually with the intended Telegram user:

1. Send `/start`
2. Send a plain text message
3. Send a command that should only work for the allowed user

Pass condition:

- message is received
- response comes from the hosted ClaudeClaw bot
- no duplicate or split ownership behavior appears

### 4. Runtime trace check

```bash
find /home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/logs -maxdepth 1 -type f | sort | tail -20
```

Pass condition:

- new Telegram log file appears after the manual test
- no evidence that the legacy Python bot is still handling the same traffic

## Immediate fail conditions

- hosted bot does not respond
- duplicate replies appear
- legacy and hosted bots both appear active on the same conversation
- `claudeclaw-hosted.service` exits or restarts unexpectedly
- dashboard health is lost

## If any fail condition happens

Run:

- `CLAUDECLAW_HOSTED_TELEGRAM_ROLLBACK_EXECUTION_SHEET.md`
