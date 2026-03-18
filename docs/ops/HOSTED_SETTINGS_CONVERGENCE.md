# Hosted Settings Convergence

Last live repro: `2026-03-17` on `openclaw-vm`

Purpose:

- make the hosted ClaudeClaw source of truth explicit
- separate live truth from historical templates
- reduce `HOME` vs workspace confusion
- make future Telegram ownership work stop depending on config archaeology

## Status Summary

- `PROVEN`: The live hosted owner is `claudeclaw-hosted.service`.
- `PROVEN`: A stale `claudeclaw.service` unit still exists on the VM, but it is now hard-deprecated and cannot be manually started.
- `PROVEN`: Live hosted behavior currently comes from several real surfaces, but they are not equal.
- `PROVEN`: `settings.canonical.json` files exist on the VM but are not enforced.
- `PROVEN`: Hosted Claude surface differs depending on whether Claude is run from `HOME` or from the hosted workspace.
- `PROVEN`: Live hosted project settings and live hosted runtime settings still drift from their adjacent canonical snapshots.
- `PROVEN`: Hosted workspace `claude-mem` exposure has been removed without changing user-level MCP or legacy services.
- `INFERRED`: The highest-value way to reduce operator confusion right now is to keep live proofs tied to the hosted workspace and keep adjacent snapshots explicitly non-authoritative.

## Canonical Source Of Truth Order

For hosted operator work, use this order and do not skip between layers without saying so explicitly.

### 1. Live hosted owner

Authoritative for runtime ownership:

- `/home/openclaw/.config/systemd/user/claudeclaw-hosted.service`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.sh`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.env`

If these disagree, the live service wins because it is what `systemd --user` is actually running.

### 2. Hosted workspace root

Authoritative for project-scoped Claude behavior:

- `/home/openclaw/claudeclaw/theclaw`

Hosted Claude proofs that care about project plugins or project MCP must run from this directory, not from `/home/openclaw`.

### 3. User-scoped Claude surface

Authoritative for user defaults and user MCP:

- `/home/openclaw/.claude/settings.json`

### 4. Workspace MCP surface

Authoritative for workspace MCP additions:

- `/home/openclaw/claudeclaw/theclaw/.mcp.json`
- `/home/openclaw/claudeclaw/theclaw/.claude/settings.local.json`

These two files jointly determine whether workspace MCP servers are actually surfaced when Claude runs from the hosted workspace.

### 5. Workspace project plugin surface

Authoritative for project plugin enablement:

- `/home/openclaw/claudeclaw/theclaw/.claude/settings.json`

### 6. Runtime-specific ClaudeClaw behavior

Authoritative for daemon behavior:

- `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`

This file governs runtime concerns like:

- model
- timezone
- web bind
- heartbeat
- Telegram config

## What Is Not A Live Source Of Truth

These files are real, but they are not authoritative for live hosted behavior unless an operator deliberately copies them into the live paths.

- `/home/openclaw/claudeclaw/theclaw/.claude/settings.canonical.json`
- `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.canonical.json`
- local repo bootstrap drafts that still use `claudeclaw.service`
- local repo startup drafts that still assume `/srv/claudeclaw` or user `claudeclaw`

## PROVEN Current Live Drift

### Unit-name drift

- `PROVEN`: `claudeclaw-hosted.service` is active and enabled.
- `PROVEN`: `claudeclaw.service` still exists, is loaded, and is disabled/inactive.
- `PROVEN`: The stale unit is now hard-deprecated with:
  - `CanStart=no`
  - `CanStop=no`
  - `RefuseManualStart=yes`
  - `RefuseManualStop=yes`
- `PROVEN`: Backup of the pre-deprecation stale unit was captured at:
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/claudeclaw.service.20260317T160709Z.bak`

### Canonical-snapshot drift

- `PROVEN`: `/home/openclaw/claudeclaw/theclaw/.claude/settings.json` does not match adjacent `settings.canonical.json`
- `PROVEN`: `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json` does not match adjacent `settings.canonical.json`

Material examples observed live:

- project plugins enabled live but set false in canonical snapshot
- live runtime timezone differs from canonical snapshot
- live runtime model differs from canonical snapshot
- live runtime Telegram config is present while canonical snapshot blanks it

### HOME vs workspace drift

- `PROVEN`: from `/home/openclaw`, `claude mcp list` does not expose the same hosted MCP surface as from the workspace
- `PROVEN`: from `/home/openclaw/claudeclaw/theclaw`, `claude mcp list` exposes `memory`, `context7`, `proton-email`, and does not expose `plugin:claude-mem:mcp-search`

## Remaining Intentional Multi-Surface Behavior

This multi-surface behavior still exists and is intentional enough that operators should treat it as a design fact, not as accidental drift:

1. `/home/openclaw/.claude/settings.json`
   Purpose: user-scoped Claude defaults and base MCP entries.
2. `/home/openclaw/claudeclaw/theclaw/.mcp.json`
   Purpose: workspace-scoped MCP additions.
3. `/home/openclaw/claudeclaw/theclaw/.claude/settings.local.json`
   Purpose: workspace-local gating for project MCP exposure.
4. `/home/openclaw/claudeclaw/theclaw/.claude/settings.json`
   Purpose: project plugin enablement.
5. `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
   Purpose: ClaudeClaw daemon behavior.

Minimum operator interpretation rule:

- user settings explain user defaults
- workspace `.mcp.json` plus workspace local settings explain project MCP
- project `.claude/settings.json` explains project plugins
- runtime `.claude/claudeclaw/settings.json` explains daemon behavior

## Minimal Convergence Applied In This Repo

- local operator docs now point to this file for hosted truth ordering
- stale `claudeclaw.service` bootstrap naming in the local VM bootstrap package is renamed to `claudeclaw-hosted.service`
- historical unit drafts remain present, but are explicitly marked non-canonical
- the live VM stale unit `claudeclaw.service` is hard-deprecated so it cannot be manually started by mistake

## Remaining Not Yet Fixed Live Drift

- `PROVEN`: live hosted project settings now set `claude-mem@thedotmack` to `false`
- `PROVEN`: live hosted `claude mcp list` no longer shows `plugin:claude-mem:mcp-search`
- `PROVEN`: live hosted runtime settings still contain Telegram configuration
- `NOT PROVEN`: whether live Telegram configuration should be removed before the cutover window or preserved until the ownership handoff

These are still real blockers or decision points, but they were not changed here because the highest-value immediate fix was operator truth convergence rather than live behavior mutation.
