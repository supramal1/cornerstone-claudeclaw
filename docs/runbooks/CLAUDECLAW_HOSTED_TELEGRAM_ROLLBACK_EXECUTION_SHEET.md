# ClaudeClaw Hosted Telegram Rollback Execution Sheet

Use this immediately if the Telegram cutover test fails.

Last updated: 2026-03-17 ~21:00 (Terminal 5 sprint scan)

## Sprint window status

- Rollback required: No (cutover succeeded, production stable)
- Rollback sentinel (`CUTOVER_ROLLBACK_SENTINEL.md`): Not present

## Rollback goal

Restore legacy Telegram ownership quickly while keeping hosted ClaudeClaw and the legacy gateway available for diagnosis.

## Rollback steps

### 0. Restore production token to legacy .env (CRITICAL)

**Before restarting legacy Telegram, the production bot token must be restored to the legacy configuration.**

During cutover, the production token was moved from `/home/openclaw/cornerstone/.env` to `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`. For rollback, this must be reversed.

```bash
# Backup current legacy .env (may have placeholder or no token)
sudo -u openclaw cp /home/openclaw/cornerstone/.env /home/openclaw/cornerstone/.env.rollback-backup

# Extract token from hosted env (the production token)
HOSTED_TOKEN=$(sudo -u openclaw grep "^BOT_TOKEN=" /home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env 2>/dev/null | cut -d= -f2-)

# Restore token to legacy .env
if [ -n "$HOSTED_TOKEN" ]; then
  sudo -u openclaw sed -i "s/^BOT_TOKEN=.*/BOT_TOKEN=$HOSTED_TOKEN/" /home/openclaw/cornerstone/.env
  echo "Token restored to legacy .env"
else
  echo "ERROR: Could not extract token from hosted env. Check backup at /home/openclaw/claudeclaw-backups/20260317T204819Z-cutover/"
  exit 1
fi
```

**Alternative: restore from backup**
```bash
# If hosted env is unavailable, restore from cutover backup
sudo -u openclaw cp /home/openclaw/claudeclaw-backups/20260317T204819Z-cutover/cornerstone-env.backup /home/openclaw/cornerstone/.env
```

### 1. Re-start legacy Telegram ownership

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user start cornerstone-telegram.service
```

Expected:

- `cornerstone-telegram.service` returns to `active (running)`

### 2. Verify legacy Telegram is back

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status cornerstone-telegram.service --no-pager

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  journalctl --user -u cornerstone-telegram.service -n 80 --no-pager
```

### 3. Leave gateway live

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status openclaw-gateway.service --no-pager
```

Expected:

- `openclaw-gateway.service` stays `active (running)`

### 4. Preserve hosted ClaudeClaw unless it is the direct cause of instability

Default action:

- keep `claudeclaw-hosted.service` running for diagnosis

If a hosted ClaudeClaw restart is explicitly needed:

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user restart claudeclaw-hosted.service
```

Do not restart any other service unless separately justified.

### 5. Record rollback evidence

```bash
sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status claudeclaw-hosted.service --no-pager

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status cornerstone-telegram.service --no-pager

sudo -n -u openclaw env XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user status openclaw-gateway.service --no-pager
```

## What rollback does not do

- does not stop `openclaw-gateway.service`
- does not retire legacy services
- does not send real email
- does not change rollback anchor contents
- does not assume any other terminal will clean up afterward
