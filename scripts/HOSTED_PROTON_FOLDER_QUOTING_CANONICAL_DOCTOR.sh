#!/usr/bin/env bash
set -euo pipefail

PROJECT="${GCP_PROJECT:-cornerstone-489916}"
ZONE="${GCP_ZONE:-europe-west2-b}"
INSTANCE="${GCP_INSTANCE:-openclaw-vm}"
LOCAL_PROOF="/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/proton-proof/prove_hosted_email_mcp_server_all_mail.py"
REMOTE_PROOF="/tmp/prove_hosted_email_mcp_server_all_mail.py"

echo "== copy proof helper =="
gcloud compute scp \
  --tunnel-through-iap \
  --project="$PROJECT" \
  --zone="$ZONE" \
  "$LOCAL_PROOF" \
  "$INSTANCE:$REMOTE_PROOF"

echo
echo "== proton mcp registration =="
gcloud compute ssh "$INSTANCE" \
  --project="$PROJECT" \
  --zone="$ZONE" \
  --tunnel-through-iap \
  --command='sudo -n -u openclaw env HOME=/home/openclaw XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000 bash -lc "cd /home/openclaw/claudeclaw/theclaw && claude mcp get proton-email"'

echo
echo "== proton bridge health =="
gcloud compute ssh "$INSTANCE" \
  --project="$PROJECT" \
  --zone="$ZONE" \
  --tunnel-through-iap \
  --command='bash -lc "sudo -n -u openclaw env HOME=/home/openclaw XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000 systemctl --user show proton-bridge.service -p ActiveState -p SubState; sudo docker inspect proton-bridge --format \"health={{.State.Health.Status}} status={{.State.Status}}\""' 

echo
echo "== canonical all-mail proof =="
gcloud compute ssh "$INSTANCE" \
  --project="$PROJECT" \
  --zone="$ZONE" \
  --tunnel-through-iap \
  --command="sudo -n -u openclaw /home/openclaw/cornerstone-integrations/.venv/bin/python $REMOTE_PROOF"
