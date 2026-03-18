# OpenClaw Rollback Preservation List

## Purpose

These artifacts must be preserved before any hosted OpenClaw retirement action and retained through the rollback window.

## Preserve For Rollback

- `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw`
- `/home/openclaw/.config/systemd/user/openclaw-gateway.service`
- `/home/openclaw/.config/systemd/user/cornerstone-telegram.service`
- `/usr/lib/node_modules/openclaw`
- `/home/openclaw/.openclaw`
- final pre-stop status and logs for:
  - `claudeclaw-hosted.service`
  - `openclaw-gateway.service`
  - `cornerstone-telegram.service`
  - any dormant `claudeclaw.service` status proving it stayed unused
- final proof that hosted ClaudeClaw was healthy at the moment of retirement:
  - dashboard response on `127.0.0.1:4632`
  - hosted `claude mcp list`
  - Telegram handoff proof
- canonical operator notes:
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CLAUDECLAW_CANONICAL_MIGRATION.md`
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_CLAUDECLAW_SPRINT_BOARD.md`

## Preserve As Historical Reference

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/openclaw-gateway.service`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/cornerstone-telegram.service`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/cornerstone-telegram-notify.service`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/tgcheck.sh`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui-openclaw.sh`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui_openclaw_acp_bridge.py`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/AIONUI_OPENCLAW.md`

## Retention Rule

- Keep rollback-critical artifacts unchanged until the rollback window is explicitly closed.
- Archive historical-reference artifacts only after the hosted ClaudeClaw path is stable and no operator workflow needs the legacy material.
