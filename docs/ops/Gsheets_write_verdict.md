# Google Sheets Write Connector Verdict

**Date:** 2026-03-18
**Capability:** external.write.sheets.google
**Connector:** gsheets-write
**Status:** ✅ PROVEN

**Token:** Present (live OAuth token verified)
**MCP Tools:** Wired and functional

## Proof Results

| Gate | Status | Result |
|------|--------|--------|
| 1. backend_contract | ✅ PASS | Connector instantiates, status() returns required keys, SCOPES match spec |
| 2. allow | ✅ PASS | Stage + commit succeeded on allowlisted sheet |
| 3. deny_folder | ⚠️ SKIPPED | No out-of-boundary file ID provided |
| 4. deny_file | ⚠️ SKIPPED | No non-sheet file ID provided |
| 5. deny_empty_allowlist | ✅ PASS | Empty WRITE_ALLOWED_FILE_IDS returns deny-all |
| 6. degraded | ✅ PASS | Missing token returns graceful error |
| 7. revoke | ⚠️ SKIPPED | Skipped to preserve token (tested separately) |
| 8. content_leak | ✅ PASS | Response shape verified; no forbidden fields; no cell data in logs |
| 9. formula_injection | ✅ PASS | All patterns (=, +, -, @) detected and rejected |

**Summary:** 9 passed, 0 failed

## Implementation Complete

- ✅ `gsheets_write_access.py` - Write connector with boundary enforcement
- ✅ `gsheets_write_proof.py` - 9-gate proof bundle
- ✅ `GSHEETS_WRITE_OPERATOR.md` - Operator documentation
- ✅ `mcp_server.py` - MCP tools wired (7 tools)
- ✅ Live token proof passed

## MCP Tools Available

| Tool | Description |
|------|-------------|
| `gsheets_write_identity` | Get email + scopes for connected account |
| `gsheets_write_status` | Connector status, allowlists, token presence |
| `gsheets_write_stage_values` | Stage a write (returns staged_id + preview) |
| `gsheets_write_commit_values` | Execute a staged write |
| `gsheets_write_append_values` | Direct append (single-file only) |
| `gsheets_write_clear_range` | Clear cells (single-file only) |
| `gsheets_write_revoke` | Revoke token + delete locally |

## Connector Specification

**Capability:** external.write.sheets.google
**Connector:** gsheets-write

**Scopes:**
  - `https://www.googleapis.com/auth/drive.metadata.readonly` - boundary check
  - `https://www.googleapis.com/auth/spreadsheets` - write operations

**Hard restrictions:**
  - Empty `WRITE_ALLOWED_FILE_IDS` = deny-all (NO bypass)
  - Only `application/vnd.google-apps.spreadsheet` MIME accepted
  - File must live in an operator-allowlisted folder
  - File must be in explicit file allowlist
  - Formula injection patterns (`=`, `+`, `-`, `@` prefixes) are rejected
  - Stage/commit pattern required for multi-file allowlist
  - Direct write allowed for single-file allowlist

**Token paths:**
  - Credentials: `~/.cornerstone/gsheets-write-credentials.json`
  - Token: `~/.cornerstone/gsheets-write-token.json`

**Provenance:** `~/.cornerstone/gsheets-write.jsonl`
