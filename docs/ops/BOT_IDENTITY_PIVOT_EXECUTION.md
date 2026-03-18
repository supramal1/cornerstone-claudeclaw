# BOT_IDENTITY_PIVOT_EXECUTION

Generated: 2026-03-17 23:06 UTC
Terminal: Terminal 1 (mutation-authorized)
VM: `openclaw-vm`

## Status Summary

Hosted ClaudeClaw was successfully pivoted so the canonical hosted Telegram identity is now `@open_claudebot` (`8229279102`).

The exact hosted owner chain is now:

1. `/home/openclaw/.config/systemd/user/claudeclaw-hosted.service`
2. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.env`
3. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
4. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/render-hosted-telegram-settings.sh`
5. `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
6. hosted journal `Bot: @open_claudebot`
7. Telegram Bot API `getMe`

`openclaw-gateway.service` was never stopped.
`cornerstone-telegram.service` was never restarted or stopped.

## Mutations performed

1. `2026-03-17 23:03:11 UTC`
   Created fresh backup dir `/home/openclaw/claudeclaw-backups/20260317T230311Z-bot-identity-pivot/` and backed up:
   - `claudeclaw-telegram.env.backup`
   - `settings.json.backup`

2. `2026-03-17 23:03:11-23:03:13 UTC`
   Attempt 1 copied historical hosted Telegram env `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/claudeclaw-telegram.env` into the canonical hosted path, rendered runtime settings, and restarted only `claudeclaw-hosted.service`.

3. `2026-03-17 23:03:25 UTC`
   Attempt 1 post-restart proof already showed:
   - hosted env/runtime token prefix `8229279102`
   - `getMe` => `@open_claudebot`
   - dashboard `HTTP/1.1 200 OK`
   - journal `Bot: @open_claudebot`

4. `2026-03-17 23:03:45-23:03:58 UTC`
   Attempt 1 automation exited before writing its success marker and auto-rolled back with the fresh backups above. Rollback proof restored:
   - hosted env/runtime token prefix `8375038775`
   - `getMe` => `@openclawlobbybot`
   - dashboard `HTTP/1.1 200 OK`
   - journal `Bot: @openclawlobbybot`

5. `2026-03-17 23:05:09 UTC`
   Created a second fresh backup dir `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/` and backed up:
   - `claudeclaw-telegram.env.backup`
   - `settings.json.backup`

6. `2026-03-17 23:05:09 UTC`
   Copied the historical hosted `@open_claudebot` env into `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`, rendered `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`, and restarted only `claudeclaw-hosted.service`.

7. `2026-03-17 23:05:54 UTC`
   Separate read-only verification proved hosted service, dashboard, env/runtime/journal, and Telegram Bot API all aligned to `@open_claudebot`.

## What is PROVEN

- `claudeclaw-hosted.service` is `active/running` with:
  - `MainPID=79360`
  - `ExecMainStartTimestamp=Tue 2026-03-17 23:05:09 UTC`
- `openclaw-gateway.service` remained `active/running` throughout the successful pass:
  - `MainPID=807`
  - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
- `cornerstone-telegram.service` remained `active/running` and was not mutated:
  - `MainPID=812`
  - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
- Hosted dashboard health after the successful pivot was `HTTP/1.1 200 OK` at `2026-03-17 23:05:54 UTC`.
- The canonical hosted Telegram source file `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env` now has:
  - token prefix `8229279102`
  - token hash16 `2b9258e532dad446`
  - allowed user `7807161252`
- The rendered runtime file `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json` now has:
  - token prefix `8229279102`
  - token hash16 `2b9258e532dad446`
  - `telegram.allowedUserIds=[7807161252]`
- Hosted env token and rendered runtime token are an exact match after the successful pivot.
- Telegram Bot API `getMe` using the live hosted token now returns:
  - `id=8229279102`
  - `username=open_claudebot`
  - `first_name=openclaude`
- Hosted journal since `2026-03-17 23:05:09 UTC` contains:
  - `TELEGRAM_CONFIG_SOURCE=/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
  - `Bot: @open_claudebot`
  - `Telegram bot started (long polling)`
- Hosted runtime state file `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/state.json` currently shows:
  - `telegram=true`
  - `web.enabled=true`
  - `web.host=127.0.0.1`
  - `web.port=4632`
  - `startedAt=1773788710083`
- The historical hosted source file used for the pivot was re-proved before mutation:
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/claudeclaw-telegram.env`
  - `getMe` for that token returned `@open_claudebot` (`8229279102`)
- The legacy Telegram unit's env `/home/openclaw/cornerstone/.env` still resolves to:
  - token prefix `8375038775`
  - `getMe` => `@openclawlobbybot` (`8375038775`)

## What is INFERRED

- There is no immediate token-level collision between the hosted runtime and the legacy Telegram unit, because the hosted canonical token now resolves to `@open_claudebot` while the legacy unit still resolves to `@openclawlobbybot`.
- The first attempt's rollback was caused by the verification automation path, not by a proven hosted runtime failure, because the same attempt had already reached clean hosted proofs for `@open_claudebot` before rollback triggered.
- Operator confusion risk remains unless the old `@openclawlobbybot` ownership story is cleaned up in adjacent docs and procedures.

## What is NOT PROVEN

- This pass did not prove end-to-end message receive/reply behavior for a fresh manual Telegram message to `@open_claudebot`.
- This pass did not prove long-term soak stability after `2026-03-17 23:05:54 UTC`.
- This pass did not prove whether `cornerstone-telegram.service` should be retired, disabled, or repointed later; it only proved that it was left untouched.

## Pivot verdict: SUCCESS

Hosted ClaudeClaw now canonically owns `@open_claudebot` through the hosted source-of-truth path.

## Exact backups created

- `/home/openclaw/claudeclaw-backups/20260317T230311Z-bot-identity-pivot/claudeclaw-telegram.env.backup`
- `/home/openclaw/claudeclaw-backups/20260317T230311Z-bot-identity-pivot/settings.json.backup`
- `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/claudeclaw-telegram.env.backup`
- `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/settings.json.backup`

Current rollback anchor for the live successful state:

- `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/`

## Exact rollback commands

Run as `openclaw` user context:

```bash
sudo -n -u openclaw cp -fp \
  /home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/claudeclaw-telegram.env.backup \
  /home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env

sudo -n -u openclaw cp -fp \
  /home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/settings.json.backup \
  /home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json

sudo -n -u openclaw env \
  HOME=/home/openclaw \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user restart claudeclaw-hosted.service

sudo -n -u openclaw env \
  HOME=/home/openclaw \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show claudeclaw-hosted.service \
  -p Id -p ActiveState -p SubState -p MainPID -p ExecMainStartTimestamp --no-pager
```

Expected rollback proof after those commands:

- hosted env/runtime token prefix returns to `8375038775`
- hosted `getMe` returns `@openclawlobbybot`
- dashboard returns `HTTP/1.1 200 OK`

## Final live bot identity

- Canonical hosted bot identity: `@open_claudebot` (`8229279102`)
- Canonical hosted token/config path: `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
- Rendered hosted runtime path: `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
- Hosted service owner: `claudeclaw-hosted.service`
- Legacy Telegram unit remains on a different bot: `@openclawlobbybot` (`8375038775`)
