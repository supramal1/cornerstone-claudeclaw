# OpenClaw Shutdown Order

## Purpose

This file defines the exact order for shutting down the hosted OpenClaw-era runtime after ClaudeClaw cutover succeeds.

The order is intentionally split into two stages:

1. Telegram handoff at cutover
2. OpenClaw gateway retirement after soak

## Stage 0: Preconditions

Do not stop anything until all of the following are proven:

- `claudeclaw-hosted.service` is healthy on the VM
- ClaudeClaw Telegram send/receive has passed
- Cornerstone MCP is healthy from the hosted ClaudeClaw workspace
- rollback anchor `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw` exists
- both legacy services are still live immediately before the first stop:
  - `openclaw-gateway.service`
  - `cornerstone-telegram.service`
- any dormant `claudeclaw.service` path is confirmed non-canonical

## Stage 1: Telegram Handoff

This is the first legacy shutdown step.

1. Freeze final pre-stop evidence for:
   - `claudeclaw-hosted.service`
   - `cornerstone-telegram.service`
   - `openclaw-gateway.service`
2. Stop `cornerstone-telegram.service`.
3. Verify ClaudeClaw Telegram remains healthy without the legacy Python bot.
4. Keep `openclaw-gateway.service` running during the soak window.

Rationale:

- Telegram ownership is the first externally visible dependency that must move off the legacy path.
- The gateway remains available as the hosted rollback fallback while ClaudeClaw proves steady-state behavior.

## Stage 2: Hosted Soak

Do not stop the gateway until the soak window proves:

- ClaudeClaw stays up under `systemd`
- Telegram stays healthy
- heartbeat and required jobs run correctly
- the laptop can be off without losing the hosted path
- no operator workflow still depends on `openclaw-gateway.service`

## Stage 3: Gateway Retirement

This is the second and final live shutdown step.

1. Re-check the rollback anchor and preserved unit copies.
2. Re-check ClaudeClaw health.
3. Stop `openclaw-gateway.service`.
4. Confirm the unit is inactive and no required workflow regressed.
5. Leave the OpenClaw package and `.openclaw` state in place for rollback until the separate cleanup window.

Rationale:

- `openclaw-gateway.service` is the last hosted OpenClaw runtime dependency.
- Stopping it before Telegram handoff and soak would remove the only proven rollback runtime too early.

## Explicit Do-Not-Do List

Do not do any of the following on cutover day:

- do not start or rely on a dormant `claudeclaw.service`
- do not delete `/home/openclaw/.openclaw`
- do not remove `/usr/lib/node_modules/openclaw`
- do not delete the preserved user unit files
- do not remove the rollback snapshot
- do not archive repo-local OpenClaw docs before the rollback window is closed
