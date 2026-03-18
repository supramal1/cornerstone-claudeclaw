#!/bin/bash
# post-cutover-service-truth-doctor.sh
# Terminal 3 - Service Ownership Verification Helper
#
# IMPORTANT: This script must run INSIDE the VM as the openclaw user.
# Run via: gcloud compute ssh openclaw-vm --zone=europe-west2-b
# Then: sudo -u openclaw -H XDG_RUNTIME_DIR=/run/user/1000 ./post-cutover-service-truth-doctor.sh

set -euo pipefail

SERVICE_OWNER="openclaw"
SERVICE_UID="1000"
XDG_RUNTIME="/run/user/${SERVICE_UID}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=================================================="
echo "Post-Cutover Service Truth Doctor"
echo "Terminal 3 Verification"
echo "=================================================="

# Must run as openclaw user
if [ "$(id -u)" != "$SERVICE_UID" ]; then
    echo -e "${RED}ERROR: This script must run as the openclaw user${NC}"
    echo "Run with: sudo -u openclaw -H XDG_RUNTIME_DIR=/run/user/1000 $0"
    exit 1
fi

echo -e "\n${YELLOW}=== Systemd Unit States ===${NC}"

for unit in claudeclaw-hosted openclaw-gateway cornerstone-telegram; do
    state=$(systemctl --user show "${unit}.service" -p ActiveState,SubState,MainPID --no-pager 2>/dev/null)
    active=$(echo "$state" | grep ActiveState= | cut -d= -f2)
    sub=$(echo "$state" | grep SubState= | cut -d= -f2)
    pid=$(echo "$state" | grep MainPID= | cut -d= -f2)

    if [ "$active" = "active" ] && [ "$sub" = "running" ]; then
        echo -e "${GREEN}✓ ${unit}.service: ${active}/${sub} (PID: ${pid})${NC}"
    elif [ "$active" = "inactive" ] && [ "$sub" = "dead" ]; then
        echo -e "${YELLOW}○ ${unit}.service: ${active}/${sub} (expected for legacy)${NC}"
    else
        echo -e "${RED}✗ ${unit}.service: ${active}/${sub} (PID: ${pid})${NC}"
    fi
done

echo -e "\n${YELLOW}=== Running Processes ===${NC}"
ps aux | grep -E "claudeclaw|openclaw-gateway" | grep -v grep

echo -e "\n${YELLOW}=== Process Cgroup Mapping ===${NC}"
for pid in $(pgrep -d '' "claudeclaw|openclaw-gateway" 2>/dev/null); do
    if [ -d "/proc/$pid" ]; then
        cgroup=$(cat "/proc/$pid/cgroup" 2>/dev/null | grep -oE '[^/]+\.service$' | head -1)
        cmd=$(ps -p "$pid" -o comm --no-headers 2>/dev/null)
        echo "PID $pid ($cmd) → $cgroup"
    fi
done

echo -e "\n${YELLOW}=== Running User Services ===${NC}"
systemctl --user list-units --type=service --state=running --no-pager

echo -e "\n${GREEN}=== Verification Complete ===${NC}"
