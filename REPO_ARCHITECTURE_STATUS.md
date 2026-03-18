# REPO_ARCHITECTURE_STATUS

Last reviewed: 2026-03-18

## Status Summary

`cornerstone-claudeclaw` is now the canonical Git repo for ClaudeClaw runtime/operator docs, hosted runbooks, repo-safe scripts, and VM bootstrap assets.

`openclaw` should now be treated as legacy/archive-only. Its remaining tracked contents are Supabase-era memory scripts, a legacy hook, and workspace bootstrap material that are not part of the ClaudeClaw + Cornerstone canonical path.

The repo-architecture question is close to done, but not fully closed with high confidence, because this scan did not find a fresh runtime-migration summary, did not find `CLAUDECLAW_REPO_VERIFICATION.md`, and did not find a tracked ClaudeClaw runtime source tree in either repo.

## Exactly what changed in this pass

1. Scanned `cornerstone-claudeclaw` and `openclaw` directly.
2. Checked for fresh pass artifacts, including `CLAUDECLAW_REPO_VERIFICATION.md` and runtime-migration summary files.
3. Re-checked `cornerstone-claudeclaw` git state and configured `origin`.
4. Compared the current tracked contents of `cornerstone-claudeclaw` and `openclaw`.
5. Added this file as the operator-facing architecture verdict.
6. Updated `README.md` so it explicitly states that `cornerstone-claudeclaw` is the canonical repo and `openclaw` is legacy/archive-only.

## What is PROVEN

1. `cornerstone-claudeclaw` is a clean git repo with configured remote:
   - `origin https://github.com/supramal1/cornerstone-claudeclaw.git`
2. The current tracked surface of `cornerstone-claudeclaw` is operator/runtime-adjacent material:
   - root `README.md`
   - `docs/`
   - `scripts/`
   - `vm-bootstrap/`
3. The current tracked surface of `openclaw` is legacy material:
   - `scripts/*.py`
   - `hooks/supabase-extract/*`
   - `workspace/BOOTSTRAP.md`
   - `workspace/skills/memory/SKILL.md`
   - `skills.txt`
4. `openclaw/workspace/skills/memory/SKILL.md` and `openclaw/hooks/supabase-extract/HOOK.md` still point at `~/.openclaw/scripts/*` and Supabase-era memory flows.
5. `docs/legacy/openclaw-retirement/RETIREMENT_CHECKLIST.md` in `cornerstone-claudeclaw` already classifies `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw` as the "OpenClaw source repo" and says to preserve it read-only after cutover, then archive it later.
6. `docs/ops/SINGLE_OWNER_OPEN_CLAUDEBOT.md` proves hosted ClaudeClaw is the current single-owner Telegram runtime and that `cornerstone-telegram.service` was stopped on 2026-03-17 23:20:04 UTC, while `openclaw-gateway.service` remained running as fallback.
7. No fresh pass artifact matching `CLAUDECLAW_REPO_VERIFICATION.md` was found in the repo scan.
8. No fresh runtime-migration summary file was found in the repo scan.
9. This scan found no tracked runtime source tree such as `src/` in either `cornerstone-claudeclaw` or `openclaw`.

## What is INFERRED

1. Future ClaudeClaw runtime/operator work should land in `cornerstone-claudeclaw`, because that repo now contains the current operator truth surfaces, hosted runbooks, doctor scripts, and retirement docs.
2. `openclaw` is no longer the repo to develop against for canonical behavior, because its remaining tracked contents are legacy helpers and bootstrap references tied to `.openclaw` and Supabase-era memory.
3. The repo architecture is operationally understandable for a fresh operator now: one canonical repo, one legacy repo, and clear neighboring repo boundaries.
4. The remaining uncertainty is not "which repo is canonical"; it is whether every repo-safe historical artifact that should be preserved has been intentionally migrated, mirrored, or explicitly left behind as archive-only.

## What is NOT PROVEN

1. This pass did not prove that every repo-safe artifact worth preserving from `openclaw` has already been copied or superseded in `cornerstone-claudeclaw`.
2. This pass did not prove that a separate Terminal 1 runtime-migration summary exists outside the scanned paths.
3. This pass did not prove that a separate Terminal 2 `CLAUDECLAW_REPO_VERIFICATION.md` exists outside the scanned paths.
4. This pass did not prove that the full ClaudeClaw runtime source is intentionally versioned in `cornerstone-claudeclaw`; no tracked source tree was present in the scanned repo.
5. This pass did not prove that `openclaw-gateway.service` can be retired yet. Repo architecture and hosted fallback retirement are related, but they are not the same closure gate.

## Canonical repo

`/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-claudeclaw`

What belongs here:

- ClaudeClaw runtime/operator docs and runbooks
- Hosted VM bootstrap assets and repo-safe service templates
- ClaudeClaw-specific doctor scripts and operator proof helpers
- Final architecture status and retirement guidance
- Any future repo-safe ClaudeClaw runtime source export, if that source is intentionally brought under version control

What does not belong here:

- token-bearing env files
- rendered machine-local runtime state
- VM backups and logs
- Cornerstone backend code
- Cornerstone integration server code
- OpenClaw-era Supabase memory hooks as active runtime dependencies

## Legacy repo

`/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/openclaw`

What belongs here now:

- preserved legacy memory scripts
- preserved OpenClaw hook examples
- preserved workspace bootstrap and skill references
- archive/forensics material needed for rollback history

What does not belong here now:

- new canonical ClaudeClaw runtime/operator development
- current operator truth docs
- new hosted cutover state
- any claim of being the canonical runtime repo

## Architecture verdict: MOSTLY CLOSED

Reason:

- The canonical repo is now clear: `cornerstone-claudeclaw`.
- The legacy repo is now clear: `openclaw`.
- The current canonical operator truth already lives in `cornerstone-claudeclaw`.
- But this pass did not find fresh cross-terminal verification artifacts or a tracked runtime source tree, so the safest honest verdict is `MOSTLY CLOSED`, not `CLOSED`.

## Exact manual follow-up, if any

1. If Terminal 2 produced `CLAUDECLAW_REPO_VERIFICATION.md`, copy or rewrite its essential conclusions into this repo so the closure record is self-contained.
2. Decide explicitly whether the absence of tracked ClaudeClaw runtime source in `cornerstone-claudeclaw` is intentional.
3. If intentional, leave `openclaw` read-only and archive-only.
4. If not intentional, export the repo-safe runtime source into `cornerstone-claudeclaw` rather than continuing to treat plugin-cache or legacy paths as the de facto source of truth.
