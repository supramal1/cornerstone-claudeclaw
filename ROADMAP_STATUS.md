# ROADMAP_STATUS

Last updated: 2026-03-18 (Updated: Cloud Run Auth Hardening Complete)
Terminal: 1 of 4 (Gateway Retirement + Security Hardening)

---

## Status Summary

**Gateway retirement completed.** The ClaudeClaw stack is now running on a single hosted service (`claudeclaw-hosted.service`). The legacy fallback (`openclaw-gateway.service`) is stopped and disabled.

**Cloud Run auth hardening: INFRA COMPLETE, UI PENDING.** The `allUsers` invoker workaround has been removed. Unauthenticated requests return 403. UI code updated locally but not yet deployed to Vercel.

**Current priorities:** Deploy UI with new auth, Google Workspace read/write capability.

---

## ⚠️ BLOCKING: UI Deployment Required

The deployed Vercel UI uses old auth code (X-API-Key only) and **will fail** against the hardened backend.

**Required steps:**
1. Commit and push UI changes (`package.json`, `lib/memory-manager.ts`)
2. Add `GCP_SERVICE_ACCOUNT_KEY` env var to Vercel
3. Redeploy

**See:** `docs/ops/CLOUD_RUN_AUTH_HARDENING.md` for exact commands

---

## Exactly What Changed in This Pass

1. Verified pre-retirement service state and health
2. Proved hosted MCP connectivity (5 connectors: memory, proton-email, context7, context-mode, claude-mem)
3. Stopped `openclaw-gateway.service` at 2026-03-18 11:16:36 UTC
4. Verified ClaudeClaw health post-retirement (dashboard 200, Telegram active)
5. Disabled `openclaw-gateway.service` to prevent auto-restart
6. Updated `docs/ops/GATEWAY_RETIREMENT_READINESS.md` with retirement evidence
7. **Created service account `cornerstone-ui-vercel` for UI authentication**
8. **Removed `allUsers` from Cloud Run invoker role**
9. **Updated UI memory-manager.ts to use IAM tokens**
10. **Verified unauthenticated access returns 403**

---

## What is PROVEN

| Item | Evidence |
|------|----------|
| Repo architecture closed | `cornerstone-claudeclaw` is canonical git repo with remote; `openclaw` is legacy/archive |
| Hosted ClaudeClaw stable | `SINGLE_OWNER_OPEN_CLAUDEBOT.md` proves Telegram ownership; active in journal |
| **Gateway retired** | `openclaw-gateway.service` stopped + disabled 2026-03-18 11:16 UTC |
| Hosted MCP healthy | `claude mcp list` shows 5 connected MCPs including Cornerstone |
| ClaudeClaw dashboard healthy | Returns HTTP 200 on `127.0.0.1:4632/` |
| Google Workspace scoped | `docs/GOOGLE_WORKSPACE_CAPABILITY_ROADMAP.md` defines build order |
| **Cloud Run IAM hardened** | Unauthenticated requests return 403; SA + user only have invoker role |

---

## What is INFERRED

| Item | Basis |
|------|-------|
| No operator workflow depends on gateway | Post-retirement verification showed no regression |

---

## What is NOT PROVEN

| Item | Why Not Proven |
|------|----------------|
| ~~GCP/VM security reviewed~~ | ✅ **RESOLVED** — Cloud Run fully hardened |
| Google Workspace write implemented | Spec only, not implemented |
| Runtime source in git | REPO_ARCHITECTURE_STATUS.md notes no tracked runtime source tree |
| UI works with new auth | Vercel deployment pending SA key env var |

---

## Roadmap Priority Order

### 1. GCP/VM SECURITY HARDENING

**Status:** ⚠️ **PARTIAL** — Infra hardened, UI deployment pending

**Actions completed:**
- [x] Migrate Cloud Run secrets to Secret Manager
- [x] Restrict Cloud Run to authenticated users only (SA + user)
- [x] Rotate all exposed API keys
- [x] Reduce default compute SA permissions
- [x] Remove `allUsers` invoker workaround
- [x] Implement service account auth for UI (local)

**Blocking:**
- [ ] Commit and push UI changes to Vercel
- [ ] Add `GCP_SERVICE_ACCOUNT_KEY` to Vercel env vars
- [ ] Verify UI works end-to-end

**Reference:** `GCP_VM_SECURITY_REVIEW.md`, `docs/ops/CLOUD_RUN_AUTH_HARDENING.md`

---

### 2. GOOGLE WORKSPACE READ/WRITE CAPABILITY

**Status:** 4/5 reads PROVEN (GSlides live-token proof pending)

**Current state:**
| Capability | Read | Write |
|------------|------|-------|
| GDrive metadata | ✅ IMPLEMENTED + PROVEN | N/A |
| GDrive content | ✅ IMPLEMENTED + PROVEN | N/A |
| GSheets | ✅ IMPLEMENTED + PROVEN | SPEC ONLY |
| GDocs | ✅ **IMPLEMENTED + LIVE-TOKEN PROVEN** | SPEC ONLY |
| GSlides | ✅ IMPLEMENTED + ⚠️ LIVE-TOKEN PROOF PENDING | SPEC ONLY |

**Read Proof Status Summary:**
| Connector | Structural | Live-Token | Verdict |
|-----------|------------|------------|---------|
| GDrive metadata | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| GDrive content | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| GSheets | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| GDocs | ✅ PASS | ✅ PASS (2026-03-18) | **✅ PROVEN** |
| GSlides | ✅ PASS | ⚠️ PENDING (gates 2, 3, 7) | **⚠️ PARTIAL** |

**Blocking:** GSlides live-token proof must pass before write work begins.

**Scope defined in:** `docs/GOOGLE_WORKSPACE_CAPABILITY_ROADMAP.md`

**Build order (updated):**
1. ~~Deploy `external.read.sheets.google` to hosted VM~~ — DONE
2. ~~Implement `external.read.docs.google` connector~~ — **DONE + LIVE-TOKEN PROVEN**
3. ~~Implement `external.read.slides.google` connector~~ — **DONE** (live-token proof pending)
4. **Gate: run `gslides_read_proof.py` with live OAuth token** — ⚠️ PENDING
5. Implement writes in order (Sheets → Docs → Slides)

---

### 3. CORNERSTONE PHASE 2+ (ONGOING)

**Status:** Phase 1 complete; Phase 2+ planned

**Scope:** Memory compression, entity resolution, graph traversal, pattern detection

**Reference:** `cornerstone/ROADMAP.md`, `cornerstone/OPERATOR.md`

---

## Closed Items

| Item | Closure Evidence |
|------|------------------|
| Repo architecture | `REPO_ARCHITECTURE_STATUS.md` — canonical repo clear, legacy repo clear |
| Hosted ClaudeClaw cutover | `SINGLE_OWNER_OPEN_CLAUDEBOT.md` — Telegram ownership proven |
| Bot identity drift | `BOT_IDENTITY_DRIFT_ROOT_CAUSE.md` — root cause identified and fixed |
| **Gateway retirement** | `docs/ops/GATEWAY_RETIREMENT_READINESS.md` — stopped + disabled 2026-03-18 |

---

## Current Service State (as of 2026-03-18 11:17 UTC)

| Service | Enabled | State |
|---------|---------|-------|
| `claudeclaw-hosted.service` | ✅ enabled | active/running |
| `openclaw-gateway.service` | ❌ disabled | inactive/dead |
| `cornerstone-telegram.service` | ✅ enabled | inactive/dead |

---

## Exact Manual Follow-up

1. **URGENT:** Rotate exposed Cloud Run API keys and migrate to Secret Manager
2. Run `HOSTED_CLAUDECLAW_DOCTOR.sh` to capture post-retirement health baseline
3. Decide Google Workspace write implementation path
4. Close rollback window after 7-day observation period

---

## Repo Quick Reference

| Repo | Purpose |
|------|---------|
| `cornerstone-claudeclaw` | Runtime/operator docs, runbooks, VM bootstrap (canonical) |
| `cornerstone` | Backend, memory manager, API, proofs |
| `cornerstone-integrations` | MCP server, connectors, client glue |
| `openclaw` | Legacy/archive only — do not develop against |
