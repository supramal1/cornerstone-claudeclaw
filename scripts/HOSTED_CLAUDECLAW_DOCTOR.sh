#!/usr/bin/env bash
set -euo pipefail

PROJECT="${GCP_PROJECT:-cornerstone-489916}"
ZONE="${GCP_ZONE:-europe-west2-b}"
INSTANCE="${GCP_INSTANCE:-openclaw-vm}"
WORKSPACE="${HOSTED_WORKSPACE:-/home/openclaw/claudeclaw/theclaw}"
ROLLBACK_ANCHOR="${ROLLBACK_ANCHOR:-/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw}"

tmp_script="$(mktemp)"
trap 'rm -f "$tmp_script"' EXIT

cat >"$tmp_script" <<'EOF'
set -euo pipefail

SERVICE_USER="openclaw"
WORKSPACE="${WORKSPACE:-/home/openclaw/claudeclaw/theclaw}"
ROLLBACK_ANCHOR="${ROLLBACK_ANCHOR:-/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw}"
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

print_header "host"
hostname

print_header "canonical services"
for unit in claudeclaw-hosted.service cornerstone-telegram.service openclaw-gateway.service proton-bridge.service; do
  printf '\n-- %s --\n' "$unit"
  run_user systemctl --user show "$unit" \
    -p Id -p LoadState -p ActiveState -p SubState -p FragmentPath -p UnitFileState \
    || true
done

print_header "dormant service warning"
if run_user systemctl --user show claudeclaw.service -p LoadState -p FragmentPath 2>/dev/null; then
  echo "WARNING: claudeclaw.service exists or is known to systemd. Treat it as dormant and non-canonical."
else
  echo "OK: no active claudeclaw.service metadata returned"
fi

print_header "dashboard"
curl -fsS -D - -o /dev/null http://127.0.0.1:4632/ || true

print_header "mcp list"
run_user bash -lc "cd '$WORKSPACE' && claude mcp list" || true

print_header "rollback anchor"
if [ -d "$ROLLBACK_ANCHOR" ]; then
  echo "OK: $ROLLBACK_ANCHOR"
else
  echo "MISSING: $ROLLBACK_ANCHOR"
fi
EOF

echo "Running hosted doctor against ${INSTANCE} (${PROJECT}/${ZONE})"
gcloud compute ssh "${INSTANCE}" \
  --project="${PROJECT}" \
  --zone="${ZONE}" \
  --tunnel-through-iap \
  --command="WORKSPACE='${WORKSPACE}' ROLLBACK_ANCHOR='${ROLLBACK_ANCHOR}' bash -s" \
  <"$tmp_script"
