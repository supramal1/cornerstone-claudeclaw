#!/usr/bin/env bash
set -euo pipefail

INSTANCE="${INSTANCE:-openclaw-vm}"
ZONE="${ZONE:-europe-west2-b}"
PROJECT="${PROJECT:-cornerstone-489916}"
VM_USER="${VM_USER:-openclaw}"
HOSTED_PY="${HOSTED_PY:-/home/openclaw/cornerstone-integrations/.venv/bin/python}"
SERVER_PATH="${SERVER_PATH:-/home/openclaw/cornerstone-integrations/email_mcp_server.py}"

run_remote_python() {
  gcloud compute ssh "$INSTANCE" \
    --zone="$ZONE" \
    --project="$PROJECT" \
    --tunnel-through-iap \
    --command="sudo -n -u $VM_USER env HOME=/home/$VM_USER $HOSTED_PY -"
}

printf '%s\n' \
  "import asyncio, importlib.util" \
  "from pathlib import Path" \
  "p = Path('$SERVER_PATH')" \
  "spec = importlib.util.spec_from_file_location('email_mcp_server', p)" \
  "mod = importlib.util.module_from_spec(spec)" \
  "spec.loader.exec_module(mod)" \
  "async def main():" \
  "    mb = await mod.call_tool('list_mailboxes', {})" \
  "    print(mb[0].text)" \
  "asyncio.run(main())" \
  | run_remote_python

printf '\n'

printf '%s\n' \
  "import asyncio, importlib.util" \
  "from pathlib import Path" \
  "p = Path('$SERVER_PATH')" \
  "spec = importlib.util.spec_from_file_location('email_mcp_server', p)" \
  "mod = importlib.util.module_from_spec(spec)" \
  "spec.loader.exec_module(mod)" \
  "async def main():" \
  "    msgs = await mod.call_tool('list_messages', {'folder': 'Archive', 'max_results': 3})" \
  "    print(msgs[0].text)" \
  "asyncio.run(main())" \
  | run_remote_python
