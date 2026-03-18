# Google Workspace Read-Gate Verdict

**Date:** 2026-03-18
**Terminal:** Terminal 2 (Security + Capability Audit)
**Verdict:** ⚠️ **PARTIAL** — 4/5 reads proven, GSlides live-token proof blocking

---

## Executive Summary

The Google Workspace read capability is **structurally complete** but **not fully proven**. Four of five read connectors have passed all 7 gates with live OAuth tokens. The fifth (GSlides) requires a live-token proof run to close gates 2, 3, and 7.

**Write work may NOT begin** until GSlides live-token proof passes.

---

## Read Capability Status Matrix

| # | Capability | Implemented | Structural Proof | Live-Token Proof | Verdict |
|---|------------|-------------|------------------|------------------|---------|
| 1 | GDrive metadata | ✅ | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| 2 | GDrive content | ✅ | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| 3 | GSheets read | ✅ | ✅ PASS | ✅ PASS | **✅ PROVEN** |
| 4 | GDocs read | ✅ | ✅ PASS | ✅ PASS (2026-03-18) | **✅ PROVEN** |
| 5 | GSlides read | ✅ | ✅ PASS | ⚠️ PENDING | **⚠️ PARTIAL** |

---

## What is PROVEN

### GDrive Metadata Read
- Connector: `gdrive_metadata_access.py`
- Proof: `gdrive_metadata_proof.py`
- All 7 gates passed with live OAuth token
- Operator doc: `GDRIVE_METADATA_OPERATOR.md`

### GDrive Content Read
- Connector: `gdrive_content_access.py`
- Proof: `gdrive_content_proof.py`
- All 7 gates passed with live OAuth token
- Operator doc: `GDRIVE_CONTENT_OPERATOR.md`

### GSheets Read
- Connector: `gsheets_read_access.py`
- Proof: `gsheets_read_proof.py`
- All 7 gates passed with live OAuth token
- Operator doc: `GSHEETS_READ_OPERATOR.md`

### GDocs Read
- Connector: `gdocs_read_access.py`
- Proof: `gdocs_read_proof.py`
- All 7 gates passed with live OAuth token (2026-03-18)
- Read 145 chars from fixture doc successfully
- Token revocation verified
- Operator doc: `GDOCS_READ_OPERATOR.md`

---

## What is PARTIAL

### GSlides Read
- Connector: `gslides_read_access.py` — ✅ IMPLEMENTED
- Proof: `gslides_read_proof.py` — ⚠️ PARTIAL
- Structural proof: ✅ PASS (gates 1, 4, 5, 6)
- Live-token proof: ⚠️ PENDING (gates 2, 3, 7)

**Blocking gates (require live OAuth token):**
| Gate | Name | Description |
|------|------|-------------|
| 2 | `allow` | Live reads against allowlisted fixture presentation |
| 3 | `deny` | Boundary enforcement for out-of-scope IDs |
| 7 | `content_leak` | Response shape verified; no text in log |

---

## Blocking Condition

**Phase 3 (Sheets Write) is BLOCKED until:**

1. Operator creates OAuth credentials for Slides API
2. Operator runs auth flow:
   ```bash
   export GSLIDES_CREDENTIALS_PATH=/path/to/client_secret.json
   export GSLIDES_TOKEN_PATH=/path/to/gslides-read-token.json
   export GSLIDES_ALLOWED_FOLDER_IDS=<folder_id>
   python gslides_read_access.py --auth
   ```
3. Operator creates fixture presentation in allowlisted folder
4. Operator runs live proof:
   ```bash
   GSLIDES_PROOF_ALLOWLISTED_PRESENTATION_ID=<id> \
   GSLIDES_PROOF_OUT_OF_BOUNDARY_FILE_ID=<id> \
   GSLIDES_PROOF_NON_PRESENTATION_FILE_ID=<id> \
   python gslides_read_proof.py
   ```
5. All 7 gates emit `[ok]`

---

## Prerequisites for Sheets Write (Phase 3)

| Prerequisite | Status |
|--------------|--------|
| GDrive metadata read proven | ✅ PASS |
| GDrive content read proven | ✅ PASS |
| GSheets read proven | ✅ PASS |
| GDocs read proven | ✅ PASS |
| **GSlides read proven** | ⚠️ **PENDING** |
| Hosted VM security gate | ✅ PASS (Cloud Run hardened) |
| Runtime tasks complete | ✅ PASS (gateway retired) |

**Gate condition: ALL 5 reads must be proven on hosted VM before any write implementation.**

---

## Files Updated

| File | Changes |
|------|---------|
| `docs/GOOGLE_WORKSPACE_CAPABILITY_ROADMAP.md` | Added authoritative read-gate verdict section; updated status to reflect 4/5 PROVEN |
| `ROADMAP_STATUS.md` | Fixed GSlides status from "SPEC ONLY" to "IMPLEMENTED + LIVE-TOKEN PROOF PENDING"; added read proof status matrix |
| `docs/ops/READ_GATE_VERDICT.md` | Created — this file |

---

## Exact Next Operator Step

```bash
# 1. Create OAuth credentials for Slides API in GCP Console

# 2. Run auth flow
cd /path/to/cornerstone-integrations
export GSLIDES_CREDENTIALS_PATH=~/.cornerstone/gslides-credentials.json
export GSLIDES_TOKEN_PATH=~/.cornerstone/gslides-read-token.json
export GSLIDES_ALLOWED_FOLDER_IDS=<your_test_folder_id>
python gslides_read_access.py --auth

# 3. Create fixture presentation in allowlisted folder

# 4. Run live proof
GSLIDES_PROOF_ALLOWLISTED_PRESENTATION_ID=<fixture_id> \
GSLIDES_PROOF_OUT_OF_BOUNDARY_FILE_ID=<out_of_boundary_id> \
GSLIDES_PROOF_NON_PRESENTATION_FILE_ID=<doc_or_sheet_id> \
python gslides_read_proof.py

# 5. Verify all gates pass
# Expected: "[ok] external.read.slides.google phase-2 proof: ALL GATES PASSED"

# 6. Update this doc with proof result
```

---

## Verdict: ⚠️ PARTIAL

**Read gate is 80% proven (4/5 connectors).**

- ✅ GDrive metadata, GDrive content, GSheets, GDocs — fully proven
- ⚠️ GSlides — implemented, structural proof passing, live-token proof pending

**Sheets write work remains BLOCKED until GSlides live-token proof passes.**
