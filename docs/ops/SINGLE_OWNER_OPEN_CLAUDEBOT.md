# SINGLE_OWNER_OPEN_CLAUDEBOT

Generated: 2026-03-17 23:21 UTC
Terminal: Terminal 1 (mutation-authorized)
VM: `openclaw-vm`

## Status Summary

Single-owner convergence succeeded.

As of the post-stop proof window ending at `2026-03-17 23:20:20 UTC`, hosted ClaudeClaw is healthy and still canonically bound to `@open_claudebot` (`8229279102`), while `cornerstone-telegram.service` is now `inactive/dead`.

`openclaw-gateway.service` was left running throughout.

## Correct-session service truth classification

Classification: `wrong-session noise`

### What is PROVEN

- In the correct `openclaw` user session at `2026-03-17 23:18:44 UTC`, `claudeclaw-hosted.service` was:
  - `ActiveState=active`
  - `SubState=running`
  - `MainPID=79360`
  - `ExecMainStartTimestamp=Tue 2026-03-17 23:05:09 UTC`
  - `ControlGroup=/user.slice/user-1000.slice/user@1000.service/app.slice/claudeclaw-hosted.service`
- `/proc/79360/cgroup` confirmed the hosted process was actually in `claudeclaw-hosted.service`.
- In that same correct-session proof, hosted config, rendered settings, journal, dashboard, and `getMe` all aligned to `@open_claudebot`.
- The default-session probe on the same VM returned:
  - `Id=claudeclaw-hosted.service`
  - `ActiveState=inactive`
  - `SubState=dead`
  - `MainPID=0`

### What is INFERRED

- The later “inactive/dead” result was caused by querying the wrong user session rather than by the current live hosted runtime actually being down.

### What is NOT PROVEN

- This pass does not independently prove whether there was a real transient hosted drop in any earlier minute before `2026-03-17 23:18:44 UTC`.
- It only proves that by the correct-session check, the hosted runtime was healthy and the wrong-session dead result was reproducible noise.

## Mutations performed

1. Re-proved hosted, legacy, and fallback unit truth from the `openclaw` user systemd session.
2. Re-proved hosted identity surfaces before mutation:
   - canonical hosted Telegram env
   - rendered hosted runtime settings
   - hosted `state.json`
   - Telegram Bot API `getMe`
   - hosted dashboard
3. Created fresh backups in:
   - `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/`
4. Stopped only:
   - `cornerstone-telegram.service`
5. Re-proved post-change single-owner state:
   - hosted still healthy
   - fallback still healthy
   - legacy unit inactive/dead
   - no fresh `409 Conflict` evidence since the stop timestamp

No hosted identity files were changed in this pass.
No gateway stop was performed.

## What is PROVEN

- Pre-stop proof at `2026-03-17 23:18:44 UTC` in the correct `openclaw` session showed:
  - `claudeclaw-hosted.service`: `active/running`, `MainPID=79360`
  - `cornerstone-telegram.service`: `active/running`, `MainPID=812`
  - `openclaw-gateway.service`: `active/running`, `MainPID=807`
- Hosted dashboard returned `HTTP/1.1 200 OK` before mutation and again after the legacy stop.
- Hosted identity before and after the stop matched exactly:
  - hosted env prefix `8229279102`
  - rendered settings prefix `8229279102`
  - token hash16 `2b9258e532dad446`
  - exact env/settings match `true`
- Telegram Bot API `getMe` for the hosted token before and after the stop returned:
  - `id=8229279102`
  - `username=open_claudebot`
  - `first_name=openclaude`
- Hosted runtime state before mutation showed:
  - `telegram=true`
  - `web.enabled=true`
  - `web.host=127.0.0.1`
  - `web.port=4632`
- Fresh backups were created at:
  - `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/claudeclaw-telegram.env.backup`
  - `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/settings.json.backup`
  - `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/state.json.backup`
  - `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/cornerstone.env.backup`
- `cornerstone-telegram.service` was stopped at `2026-03-17 23:20:04 UTC`.
- Post-stop proof at `2026-03-17 23:20:20 UTC` showed:
  - `cornerstone-telegram.service`: `inactive/dead`, `MainPID=0`
  - `claudeclaw-hosted.service`: still `active/running`, still `MainPID=79360`
  - `openclaw-gateway.service`: still `active/running`, still `MainPID=807`
- Fresh post-stop conflict scan since `2026-03-17 23:20:04 UTC` found:
  - `HOSTED_409_SINCE_STOP=0`
  - `LEGACY_409_SINCE_STOP=0`
- Legacy journal since stop recorded:
  - `Stopping cornerstone-telegram.service - Cornerstone Telegram Bot...`
  - `Stopped cornerstone-telegram.service - Cornerstone Telegram Bot.`

## What is INFERRED

- The previously observed `409 Conflict` storm was caused by parallel polling posture before single-owner convergence, and that specific conflict evidence is no longer appearing after the legacy unit was stopped.
- Hosted ClaudeClaw is now the only currently proven active Telegram poll owner in the VM runtime posture.

## What is NOT PROVEN

- This pass did not prove an end-to-end manual message/reply smoke on `@open_claudebot` after single-owner convergence.
- This pass did not prove long-duration soak stability beyond the immediate post-stop window.
- This pass did not prove that no other external process outside the proven systemd units could ever poll this bot later; it only proved no fresh conflict evidence in the checked post-stop window.

## Convergence verdict: SUCCESS

Hosted ClaudeClaw is now in a single-owner runtime state on `@open_claudebot`, with the legacy Telegram unit no longer actively polling.

## Exact backups created

- `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/claudeclaw-telegram.env.backup`
- `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/settings.json.backup`
- `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/state.json.backup`
- `/home/openclaw/claudeclaw-backups/20260317T232003Z-single-owner-open-claudebot/cornerstone.env.backup`

## Exact rollback commands

Run as the `openclaw` user session:

```bash
sudo -n -u openclaw env \
  HOME=/home/openclaw \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user start cornerstone-telegram.service

sudo -n -u openclaw env \
  HOME=/home/openclaw \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show cornerstone-telegram.service \
  -p Id -p ActiveState -p SubState -p MainPID -p ExecMainStartTimestamp --no-pager

sudo -n -u openclaw env \
  HOME=/home/openclaw \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show claudeclaw-hosted.service \
  -p Id -p ActiveState -p SubState -p MainPID -p ExecMainStartTimestamp --no-pager
```

The fresh file backups above are preserved, but no file restore is required for this rollback because this pass changed runtime state only by stopping the legacy unit.

## Final live hosted bot identity

- `@open_claudebot` (`8229279102`)

## Final legacy unit state

- `cornerstone-telegram.service`
- `ActiveState=inactive`
- `SubState=dead`
- `MainPID=0`
