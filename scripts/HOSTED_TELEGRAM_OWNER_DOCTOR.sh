#!/usr/bin/env bash
set -euo pipefail

PROJECT="${GCP_PROJECT:-cornerstone-489916}"
ZONE="${GCP_ZONE:-europe-west2-b}"
INSTANCE="${GCP_INSTANCE:-openclaw-vm}"

tmp_script="$(mktemp)"
trap 'rm -f "$tmp_script"' EXIT

cat >"$tmp_script" <<'EOF'
set -euo pipefail

SERVICE_USER="openclaw"
WORKSPACE="/home/openclaw/claudeclaw/theclaw"
RUNTIME_SETTINGS="$WORKSPACE/.claude/claudeclaw/settings.json"
HOSTED_UNIT="claudeclaw-hosted.service"
LEGACY_UNIT="cornerstone-telegram.service"
ALT_UNIT="claudeclaw.service"
uid="$(id -u "$SERVICE_USER")"

run_user() {
  sudo -n -u "$SERVICE_USER" env \
    HOME="/home/${SERVICE_USER}" \
    XDG_RUNTIME_DIR="/run/user/${uid}" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" \
    "$@"
}

print_header() {
  printf '\n== %s ==\n' "$1"
}

print_header "legacy live telegram owner"
run_user systemctl --user show "$LEGACY_UNIT" \
  -p Id -p LoadState -p ActiveState -p SubState -p FragmentPath -p ExecStart -p WorkingDirectory -p EnvironmentFiles \
  || true

print_header "hosted claudeclaw candidate owner"
run_user systemctl --user show "$HOSTED_UNIT" \
  -p Id -p LoadState -p ActiveState -p SubState -p FragmentPath -p ExecStart -p WorkingDirectory -p EnvironmentFiles \
  || true

print_header "dormant alternate unit"
if run_user systemctl --user show "$ALT_UNIT" -p LoadState -p ActiveState -p SubState -p FragmentPath 2>/dev/null; then
  echo "WARNING: $ALT_UNIT exists and is non-canonical"
else
  echo "OK: no active metadata for $ALT_UNIT"
fi

print_header "telegram runtime settings summary"
run_user python3 - <<'PY'
import json, pathlib
path = pathlib.Path('/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json')
data = json.loads(path.read_text())
tg = data.get('telegram', {})
web = data.get('web', {})
print(f'path={path}')
print('telegram.token_present=' + str(bool(tg.get('token'))))
print('telegram.allowed_user_count=' + str(len(tg.get('allowedUserIds', []))))
print('telegram.keys=' + ','.join(sorted(tg.keys())))
print('web.host=' + str(web.get('host')))
print('web.port=' + str(web.get('port')))
PY

print_header "telegram runtime state summary"
run_user python3 - <<'PY'
import json, pathlib
path = pathlib.Path('/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/state.json')
data = json.loads(path.read_text())
print(f'path={path}')
print('telegram=' + str(data.get('telegram')))
web = data.get('web', {})
print('web.enabled=' + str(web.get('enabled')))
print('web.host=' + str(web.get('host')))
print('web.port=' + str(web.get('port')))
PY

print_header "recent hosted telegram journal refs"
run_user journalctl --user -u "$HOSTED_UNIT" -n 80 --no-pager | \
  grep -Ei 'Telegram: enabled|Telegram bot started|Allowed users|Running: telegram|Done: telegram' | \
  sed -E 's/(Allowed users: ).*/\1<redacted>/' || true

print_header "hosted mcp list"
run_user bash -lc "cd '$WORKSPACE' && claude mcp list" || true
EOF

echo "Running hosted Telegram owner doctor against ${INSTANCE} (${PROJECT}/${ZONE})"
gcloud compute ssh "${INSTANCE}" \
  --project="${PROJECT}" \
  --zone="${ZONE}" \
  --tunnel-through-iap \
  --command='bash -s' \
  <"$tmp_script"
