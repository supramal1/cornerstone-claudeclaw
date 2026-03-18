# Cloud Run Auth Hardening - Complete

**Date:** 2026-03-18
**Status:** ⚠️ **PARTIAL** — Infra hardened, UI deployment pending

---

## Current State

| Component | Status | Notes |
|-----------|--------|-------|
| Cloud Run IAM | ✅ HARDENED | Only SA + user can invoke |
| Backend (FastAPI) | ✅ OPERATIONAL | X-API-Key enforced |
| UI Code | ✅ UPDATED | IAM token auth implemented locally |
| UI Deployment | ❌ PENDING | Changes not committed/pushed |
| Vercel Env Vars | ❌ PENDING | `GCP_SERVICE_ACCOUNT_KEY` not set |

---

## Blocking Issue

The deployed Vercel UI is still using the old auth code (X-API-Key only). It cannot reach the hardened backend because:
1. `google-auth-library` dependency not in deployed package.json
2. `memory-manager.ts` doesn't have IAM token code
3. `GCP_SERVICE_ACCOUNT_KEY` env var not set in Vercel

**Result:** UI will return 500/403 errors on protected endpoints.

---

## Required Steps to Complete

### 1. Commit and Push UI Changes

```bash
cd /Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/Projects/cornerstone-ui

# Stage changes
git add package.json lib/memory-manager.ts .env.local.example

# Commit
git commit -m "feat: add IAM token auth for Cloud Run backend

- Add google-auth-library dependency
- Update memory-manager.ts to use service account ID tokens
- Add GCP_SERVICE_ACCOUNT_KEY env var support

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"

# Push
git push origin main
```

### 2. Add Vercel Environment Variable

```bash
# Get the SA key (minified)
cat /tmp/cornerstone-ui-vercel-key.json | tr -d '\n' | pbcopy
```

Then in Vercel dashboard:
1. Go to Project Settings → Environment Variables
2. Add `GCP_SERVICE_ACCOUNT_KEY` with the copied JSON string
3. Redeploy

### 3. Verify Deployment

```bash
# After Vercel rebuilds, test the UI
curl -s "https://cornerstone-ui.vercel.app/memory/recent"
# Should return JSON, not 500/403
```

---

## Summary

The Cloud Run `cornerstone-api` service is now properly hardened with IAM-based authentication. The `allUsers` invoker workaround has been removed.

---

## What Changed

| Item | Before | After |
|------|--------|-------|
| Cloud Run IAM Invoker | `allUsers` + `user:malik` | `serviceAccount:cornerstone-ui-vercel` + `user:malik` |
| Unauthenticated access | 200/401 (reached app) | 403 (blocked at infra) |
| UI authentication | X-API-Key only | IAM Bearer token + X-API-Key |

---

## Architecture

```
┌─────────────┐      ┌──────────────────────────────────────┐
│   Vercel    │      │           GCP Cloud Run              │
│   (UI)      │      │                                      │
│             │      │  ┌─────────────────────────────┐     │
│  Next.js    │──────┼──►  cornerstone-api           │     │
│  Server     │      │  │  (FastAPI)                  │     │
│  Component  │      │  │                             │     │
│             │      │  │  IAM: SA + user only        │     │
│  Uses SA    │      │  │  App: X-API-Key required    │     │
│  key for    │      │  │                             │     │
│  ID tokens  │      │  └─────────────────────────────┘     │
└─────────────┘      └──────────────────────────────────────┘
```

**Auth flow:**
1. UI loads SA key from `GCP_SERVICE_ACCOUNT_KEY` env var
2. Uses Google Auth Library to get OIDC ID token
3. Sends `Authorization: Bearer <id_token>` header
4. Cloud Run IAM validates token, allows request
5. FastAPI validates `X-API-Key` for protected endpoints

---

## Vercel Deployment

### Required Environment Variables

| Variable | Description |
|----------|-------------|
| `MEMORY_API_BASE_URL` | Cloud Run URL (e.g., `https://cornerstone-api-...run.app`) |
| `MEMORY_API_KEY` | App-layer API key |
| `GCP_SERVICE_ACCOUNT_KEY` | JSON string of service account key |

### Setting GCP_SERVICE_ACCOUNT_KEY

1. The SA key file is at `/tmp/cornerstone-ui-vercel-key.json` (local)
2. Minify the JSON (remove newlines)
3. Add to Vercel env as `GCP_SERVICE_ACCOUNT_KEY`

```bash
# Minify the key for env var
cat /tmp/cornerstone-ui-vercel-key.json | tr -d '\n'
```

### Install Dependencies

After deploying, run in Vercel:
```bash
npm install google-auth-library
```

Or the package.json has been updated to include it.

---

## Verification

### Unauthenticated Access (Should Fail)

```bash
curl -s -w "\nHTTP: %{http_code}" \
  "https://cornerstone-api-34862349933.europe-west2.run.app/health"
# Expected: 403 Forbidden
```

### Authenticated Access (Should Work)

```bash
# Using service account key
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/cornerstone-ui-vercel-key.json
TOKEN=$(gcloud auth print-identity-token)

curl -s -w "\nHTTP: %{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  "https://cornerstone-api-34862349933.europe-west2.run.app/health"
# Expected: 200 OK

curl -s -w "\nHTTP: %{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-API-Key: $MEMORY_API_KEY" \
  "https://cornerstone-api-34862349933.europe-west2.run.app/memory/recent"
# Expected: 200 OK with JSON response
```

---

## Current IAM Policy

```
bindings:
- members:
  - serviceAccount:cornerstone-ui-vercel@cornerstone-489916.iam.gserviceaccount.com
  - user:malik.roberts@gmail.com
  role: roles/run.invoker
```

---

## Files Modified

| File | Change |
|------|--------|
| `cornerstone-ui/package.json` | Added `google-auth-library` dependency |
| `cornerstone-ui/lib/memory-manager.ts` | Added IAM token authentication |
| `cornerstone-ui/.env.local.example` | Added `GCP_SERVICE_ACCOUNT_KEY` |
| `GCP_VM_SECURITY_REVIEW.md` | Updated with completion status |

---

## Security Posture

| Layer | Status |
|-------|--------|
| Infra-level (Cloud Run IAM) | ✅ HARDENED - Only SA + user can invoke |
| App-level (FastAPI) | ✅ ENFORCED - X-API-Key required for protected |
| Secrets | ✅ SECURED - Secret Manager with secretKeyRef |
| Service Account | ✅ HARDENED - Dedicated SA with minimal roles |

---

## Rollback (If Needed)

If UI breaks after deployment:

```bash
# Re-add allUsers temporarily
gcloud run services add-iam-policy-binding cornerstone-api \
  --project=cornerstone-489916 \
  --region=europe-west2 \
  --member="allUsers" \
  --role="roles/run.invoker"
```

---

## References

- `GCP_VM_SECURITY_REVIEW.md` - Full security audit
- `cornerstone-ui/lib/memory-manager.ts` - Auth implementation
