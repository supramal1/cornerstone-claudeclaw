# ClaudeClaw Canonical Migration Plan

Status: active canonical migration note

Operator entry point:

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_OPERATOR_START_HERE.md`

Hosted-current note:

- Canonical hosted runtime owner is `claudeclaw-hosted.service`.
- Manual hosted `nohup` start is rollback-only.
- `cornerstone-telegram.service` remains the live legacy Telegram owner until cutover.
- `openclaw-gateway.service` remains the hosted rollback and fallback runtime.
- Proton Bridge MCP is connected.
- Telegram cutover is not done yet.
- If `claudeclaw.service` still exists anywhere on the VM, treat it as dormant and non-canonical.

Historical note:

- Sections below that describe local Mac runtime ownership, missing hosted prerequisites, or draft `claudeclaw.service` naming are historical planning context unless a newer hosted note overrides them.

## Purpose

This document is the canonical operator plan for replacing OpenClaw with ClaudeClaw.

Target state:

- ClaudeClaw is the only canonical runtime.
- Cornerstone is the only canonical memory backend.
- Telegram is ClaudeClaw-owned.
- The hosted VM is the always-on runtime when the laptop is off.
- The dashboard remains localhost-only at first.
- OpenClaw becomes a frozen legacy path and is retired only after parity is proven.
- `claude-mem` is not part of the canonical path.

This plan is intentionally sequential and conservative. It separates local canonicalization from hosted cutover and requires parity proof before any retirement step.

## Current Proven State

### Local

- Historical reference only:
  - local ClaudeClaw has since been removed from the Mac
  - local slash-command startup is no longer part of the active hosted operator path

### Hosted VM

- Hostname: `openclaw-vm`
- Status: running
- OS: Debian 12
- Canonical hosted ClaudeClaw owner:
  - `claudeclaw-hosted.service`
- Current legacy fallback services remain live:
  - `openclaw-gateway.service`
  - `cornerstone-telegram.service`
- Current hosted Telegram is still the legacy Python bot.
- Hosted Claude auth is working for user `openclaw`.
- Hosted Cornerstone MCP now connects when configured to use:
  - `/home/openclaw/cornerstone-integrations/.venv/bin/python`
  - `/home/openclaw/cornerstone-integrations/mcp_server.py`
- Proton Bridge MCP is connected.
- Manual hosted `nohup` startup is rollback-only after service ownership promotion.
- If a `claudeclaw.service` unit or note still exists on the VM, it is dormant and non-canonical.

## Runtime Code vs Workspace State

This distinction is mandatory for the migration.

| Layer | Meaning | Local proven example | VM target implication |
|---|---|---|---|
| Runtime code | Executable runtime and plugin install | `~/.claude/plugins/cache/claudeclaw/claudeclaw/1.0.0/src/index.ts` | Must be recreated on the VM with its own Claude install, plugin cache, and toolchain |
| Workspace state | The `process.cwd()` project that ClaudeClaw writes into | `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/.claude/claudeclaw` | Must exist on the VM as a stable local filesystem path, not as a copied Mac path |
| Memory backend | Canonical memory system | Cornerstone MCP | Must be recreated with VM-valid command paths and become the only canonical memory path |
| Legacy runtime state | Old hosted path | `/home/openclaw/.openclaw` and OpenClaw services | Must remain intact until ClaudeClaw parity is proven, then be retired cleanly |

## Key Risks

### OneDrive Workspace Risk

Local workspace state lives inside a OneDrive-synced path:

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw`

ClaudeClaw writes active runtime artifacts into the workspace:

- `.claude/claudeclaw/settings.json`
- `.claude/claudeclaw/session.json`
- `.claude/claudeclaw/state.json`
- `.claude/claudeclaw/logs/`
- `.claude/claudeclaw/jobs/`
- `.claude/claudeclaw/whisper/`

Risk:

- sync latency
- file locking or conflict copies
- accidental propagation of machine-specific state
- poor fit for an always-on canonical runtime

Conservative rule:

- The laptop can continue to use the OneDrive path during migration, but the VM canonical runtime must use a stable VM-local path, not a synced desktop path.

### Memory Split Risk

Local memory is currently split between:

- Cornerstone MCP
- `claude-mem` sidecar

Risk:

- non-deterministic memory source of truth
- divergence between local and hosted behavior
- false parity if ClaudeClaw appears correct locally but differs on the VM

Conservative rule:

- parity is only proven when ClaudeClaw behavior is validated with Cornerstone as the only canonical memory backend
- `claude-mem` may remain temporarily installed locally during transition, but it is not part of the target architecture

### VM OpenClaw-Shaped Risk

The VM currently has a working legacy runtime:

- `openclaw-gateway.service`
- `cornerstone-telegram.service`

Risk:

- premature service changes could break the only always-on path
- Telegram ownership is still tied to legacy infrastructure
- hosted parity cannot be assumed from local success

Conservative rule:

- no OpenClaw retirement step happens until ClaudeClaw parity is proven on the VM

## Dependency Map

### Canonical local path

- Claude runtime code:
  - `~/.claude/plugins/cache/claudeclaw/claudeclaw/1.0.0`
- ClaudeClaw workspace:
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw`
- Local MCP config:
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/.mcp.json`
- Local Claude settings:
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/.claude/settings.json`
- Local ClaudeClaw settings:
  - `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/.claude/claudeclaw/settings.json`

### Canonical hosted path to create

Historical planning note:

- the service name in this older planning section predates the current hosted ownership decision
- the current canonical hosted owner is `claudeclaw-hosted.service` under the `openclaw` user

- Hosted runtime user:
  - choose one user and keep it stable for the runtime
- Hosted Claude home:
  - `~/.claude`
- Hosted ClaudeClaw plugin cache:
  - `~/.claude/plugins/...`
- Hosted ClaudeClaw workspace:
  - a VM-local path dedicated to canonical ClaudeClaw state
- Hosted Cornerstone MCP config:
  - VM-valid config with Linux paths only
- Hosted service wrapper:
  - one systemd-managed ClaudeClaw service
- Hosted Telegram ownership:
  - ClaudeClaw only

### Legacy hosted path to retire later

- `/home/openclaw/.config/systemd/user/openclaw-gateway.service`
- `/home/openclaw/.config/systemd/user/cornerstone-telegram.service`
- `/home/openclaw/.openclaw`
- `/usr/lib/node_modules/openclaw`

## Phase Plan

## Phase 1: Local Canonicalization

Goal:

- define the exact local canonical shape that the VM must replicate

Operator sequence:

1. Freeze the canonical local reference paths:
   - runtime code path
   - workspace state path
   - MCP config path
   - ClaudeClaw settings path
2. Treat Cornerstone as canonical memory in all planning and parity checks.
3. Record `claude-mem` as non-canonical and exclude it from parity criteria.
4. Keep the current operator-driven startup model as the local reference behavior.
5. Explicitly document the local dashboard policy as localhost-only.
6. Record the current local security posture as transitional only:
   - current local ClaudeClaw security is `unrestricted`
   - this is not the recommended hosted target without an explicit risk sign-off

Exit criteria:

- there is one written reference for the local canonical runtime shape
- the parity checklist does not depend on `claude-mem`
- the VM target is defined as a recreation of ClaudeClaw plus Cornerstone, not a copy of OpenClaw

## Phase 2: VM Bootstrap

Goal:

- prepare the hosted VM so ClaudeClaw can exist alongside the legacy stack without cutover yet

Operator sequence:

1. Choose the hosted ClaudeClaw runtime user.
   - Conservative default: create or dedicate a single runtime user and do not mix with the operator account.
2. Choose the hosted ClaudeClaw workspace path.
   - Must be VM-local, stable, and not synced from OneDrive.
3. Install the missing runtime prerequisites on the VM:
   - Claude CLI
   - Bun
   - any required Node support that ClaudeClaw expects
4. Create the hosted Claude home:
   - `~/.claude`
5. Install ClaudeClaw into the hosted Claude plugin cache.
6. Recreate only the required hosted Claude settings:
   - plugin enablement for ClaudeClaw
   - MCP config for Cornerstone
7. Create a VM-valid Cornerstone MCP config with Linux paths only.
8. Recreate hosted ClaudeClaw workspace state structure in the chosen workspace:
   - `.claude/claudeclaw/settings.json`
   - jobs path
   - logs path
   - prompt override path if needed
9. Configure hosted ClaudeClaw for:
   - model
   - fallback if desired
   - timezone
   - heartbeat
   - Telegram
   - dashboard host `127.0.0.1`
10. Create a new systemd service wrapper for ClaudeClaw only.
11. Do not stop or replace OpenClaw yet.

Exit criteria:

- hosted VM has Claude runtime prerequisites
- hosted VM has ClaudeClaw installed
- hosted VM has VM-valid Cornerstone MCP config
- hosted VM has a dedicated ClaudeClaw workspace path
- hosted VM has a ClaudeClaw service definition ready for controlled bring-up

## Phase 3: Hosted Parity Proof

Goal:

- prove that hosted ClaudeClaw can replace the legacy hosted path without losing always-on behavior

Operator sequence:

1. Start ClaudeClaw on the VM without retiring OpenClaw yet.
2. Keep the dashboard localhost-only.
3. Verify ClaudeClaw can:
   - start cleanly under systemd
   - persist session and state in its hosted workspace
   - read Cornerstone via MCP
   - send and receive Telegram messages
   - run heartbeat/jobs while the laptop is off
4. Compare hosted ClaudeClaw behavior against the required capabilities, not against implementation details.
5. Run a soak period.
   - Observe stability over enough time to cover:
     - process restart behavior
     - Telegram message handling
     - at least one scheduled heartbeat
     - at least one scheduled job if jobs are part of the target
6. Verify the legacy hosted OpenClaw path is no longer needed for any canonical capability.

Hosted parity is proven only if all of the following are true:

- ClaudeClaw runs on the VM without the laptop
- Cornerstone MCP is the only canonical memory backend used for acceptance
- Telegram is ClaudeClaw-owned
- dashboard access is not required for mission-critical operation
- no canonical capability still depends on OpenClaw

Exit criteria:

- hosted parity proof is complete
- OpenClaw is no longer required for canonical runtime behavior

## Phase 4: OpenClaw Retirement

Goal:

- retire the legacy hosted path cleanly after parity proof

Operator sequence:

1. Freeze a rollback snapshot of the legacy service definitions and runtime references.
2. Switch canonical ownership declaration:
   - ClaudeClaw is canonical
   - OpenClaw is legacy-only
3. Remove Telegram from the legacy path only after ClaudeClaw Telegram has passed parity.
4. Disable and retire legacy OpenClaw services.
5. Preserve legacy artifacts long enough for rollback, then archive or remove them under a separate change window.

Exit criteria:

- no production traffic or operator workflow depends on OpenClaw
- hosted runtime is solely ClaudeClaw
- Cornerstone remains the only canonical memory backend

## Recommended Cutover Order

1. Canonicalize the local reference shape.
2. Build the hosted ClaudeClaw runtime on the VM in parallel with the legacy stack still intact.
3. Recreate Cornerstone MCP on the VM with Linux paths.
4. Bring up hosted ClaudeClaw under systemd with dashboard localhost-only.
5. Validate Telegram on ClaudeClaw.
6. Validate heartbeat/jobs on ClaudeClaw.
7. Run hosted soak/parity proof.
8. Declare go or no-go using the checklist below.
9. On go, transfer canonical ownership to ClaudeClaw.
10. Only then retire OpenClaw services.

## Go / No-Go Checklist For Cutover Day

### Go

- VM has `claude` installed and callable.
- VM has `bun` installed and callable.
- VM has ClaudeClaw installed in the hosted plugin cache.
- VM has a stable hosted workspace path for ClaudeClaw state.
- VM has VM-valid Cornerstone MCP config with Linux paths only.
- ClaudeClaw starts under systemd and survives restart.
- Telegram send/receive works through ClaudeClaw.
- Heartbeat runs through ClaudeClaw.
- Any required jobs run through ClaudeClaw.
- Dashboard, if enabled, is bound to `127.0.0.1` only.
- Acceptance testing does not rely on `claude-mem`.
- OpenClaw is no longer needed for any canonical capability.
- Rollback artifacts are captured before service retirement.

### No-Go

- `claude` missing on the VM
- `bun` missing on the VM
- no ClaudeClaw install on the VM
- hosted MCP config still points to Mac paths
- Telegram still depends on the legacy Python bot
- ClaudeClaw cannot operate with the laptop off
- parity proof was not completed
- rollback path is not ready

## Rollback Plan

Rollback principle:

- retire nothing irreversible on the first successful ClaudeClaw start
- preserve the working OpenClaw path until hosted ClaudeClaw has proven stability

Rollback sequence if hosted ClaudeClaw fails before retirement:

1. Keep OpenClaw as the active hosted path.
2. Stop using ClaudeClaw for parity testing.
3. Preserve logs, unit files, and hosted workspace state for diagnosis.
4. Fix forward in a later change window.

Rollback sequence if a cutover is attempted and fails:

1. Reassign canonical status back to OpenClaw temporarily.
2. Re-enable legacy Telegram ownership.
3. Re-enable legacy hosted services from the preserved unit definitions.
4. Leave ClaudeClaw artifacts in place for debugging, but do not treat them as canonical.
5. Re-run parity proof before any second retirement attempt.

Artifacts to preserve before retirement:

- OpenClaw unit files
- Telegram unit files
- hosted OpenClaw config and state paths
- hosted ClaudeClaw unit file
- hosted ClaudeClaw workspace path
- cutover-day notes and validation logs

## Open Questions And Blockers

### Blockers

- VM currently has no `claude` CLI.
- VM currently has no `bun`.
- VM currently has no ClaudeClaw install.
- VM currently has no valid hosted Cornerstone MCP config for ClaudeClaw.
- Telegram is still owned by the legacy Python bot.
- OpenClaw is still the only proven always-on hosted runtime.

### Open Questions

- Which VM user should own the canonical ClaudeClaw runtime?
- What exact VM-local path should become the canonical ClaudeClaw workspace root?
- What hosted security level should ClaudeClaw run with on the VM?
- Do any current hosted behaviors rely on OpenClaw-specific features that ClaudeClaw does not yet cover?
- When local cleanup happens, what is the explicit procedure for removing `claude-mem` from the accepted runtime path without disrupting the operator workflow?

## Operator Notes

- This document supersedes the older webhook-first mental model for the hosted migration.
- The current file `gcp_claude_code_architecture.md` is useful as historical context, but the actual migration target is a direct ClaudeClaw daemon on the VM, not a new OpenClaw-style gateway architecture.
