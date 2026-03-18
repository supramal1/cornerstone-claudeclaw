#!/usr/bin/env bash

set -euo pipefail

VM_NAME="${VM_NAME:-openclaw-vm}"
VM_ZONE="${VM_ZONE:-europe-west2-b}"
VM_PROJECT="${VM_PROJECT:-cornerstone-489916}"

gcloud compute ssh "$VM_NAME" \
  --zone="$VM_ZONE" \
  --project="$VM_PROJECT" \
  --tunnel-through-iap \
  --command='sudo -n -u openclaw env HOME=/home/openclaw XDG_RUNTIME_DIR=/run/user/1000 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000 bash -lc "
printf \"==claudeclaw-hosted.service==\\n\"
systemctl --user show claudeclaw-hosted.service --property=ActiveState,SubState,WorkingDirectory --no-pager
printf \"\\n==legacy-services==\\n\"
printf \"cornerstone-telegram.service\\n\"
systemctl --user show cornerstone-telegram.service --property=ActiveState,SubState --no-pager
printf \"openclaw-gateway.service\\n\"
systemctl --user show openclaw-gateway.service --property=ActiveState,SubState --no-pager
printf \"\\n==workspace==\\n\"
cd /home/openclaw/claudeclaw/theclaw
pwd
printf \"\\n==claude-mem-flag==\\n\"
python3 -c \"import json; print(json.load(open(\\\".claude/settings.json\\\", \\\"r\\\", encoding=\\\"utf-8\\\"))[\\\"enabledPlugins\\\"].get(\\\"claude-mem@thedotmack\\\"))\"
printf \"\\n==mcp-list==\\n\"
claude mcp list | grep -E \"claude-mem|memory:|context7:|proton-email:|plugin:context-mode|claude.ai Google Calendar|claude.ai Gmail\" || true
printf \"\\n==plugin-list==\\n\"
claude plugin list | sed -n \"/claude-mem@thedotmack/,+3p\"
printf \"\\n==mcp-get-memory==\\n\"
claude mcp get memory
printf \"\\n==mcp-get-proton==\\n\"
claude mcp get proton-email
"'
