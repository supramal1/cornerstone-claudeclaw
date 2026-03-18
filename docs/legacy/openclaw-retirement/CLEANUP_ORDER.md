# OpenClaw Cleanup Order

## Purpose

This file defines the cleanup sequence that happens only after:

- hosted ClaudeClaw cutover passed
- hosted soak passed
- the gateway has already been stopped
- the rollback window has been explicitly closed

Cleanup is a separate change window from shutdown.

## Cleanup Order

1. Freeze final rollback materials.
   - Preserve copies of the legacy user units.
   - Preserve the rollback snapshot.
   - Preserve the final hosted OpenClaw state tree.
2. Mark OpenClaw as retired in canonical docs.
   - Keep the migration history.
   - Remove language that treats OpenClaw as current or fallback-canonical.
3. Archive repo-local legacy references.
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/openclaw-gateway.service`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/cornerstone-telegram.service`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/cornerstone-telegram-notify.service`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone/ops/tgcheck.sh`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui-openclaw.sh`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/aionui_openclaw_acp_bridge.py`
   - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-integrations/clients/AIONUI_OPENCLAW.md`
4. Remove hosted OpenClaw runtime code only after the archive is complete.
   - `/usr/lib/node_modules/openclaw`
5. Remove hosted OpenClaw state only after runtime code removal is no longer needed for rollback.
   - `/home/openclaw/.openclaw`
6. Remove or archive stale hosted config references that were part of the OpenClaw-era path.
   - `/home/openclaw/cornerstone-integrations/.claude/mcp.json`
7. Re-run a final post-cleanup validation.
   - ClaudeClaw still healthy
   - Telegram still healthy
   - Cornerstone MCP still healthy
   - no required operator workflow still references OpenClaw paths

## Archive-First Rule

Apply archive-first handling to anything that is documentation, reference material, or forensic evidence:

- unit reference copies in repos
- old operator scripts
- old OpenClaw workspace bootstrap docs
- AionUI OpenClaw bridge docs
- cutover notes and proof logs

Use direct removal only for the hosted runtime code and hosted runtime state, and only after the rollback window is closed.

## What Should Still Exist After Cleanup

The following should remain after cleanup:

- ClaudeClaw service ownership artifacts
- ClaudeClaw VM bootstrap package
- Cornerstone MCP server and supporting integrations
- non-OpenClaw Cornerstone infrastructure that has separate duties, such as Proton Bridge, if still in use
- migration history and rollback notes required for auditability
