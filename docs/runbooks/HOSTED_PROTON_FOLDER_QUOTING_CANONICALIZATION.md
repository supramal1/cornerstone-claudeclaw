# Hosted Proton Folder Quoting Canonicalization

Status: active hosted Proton operator note

Read-only helper:

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_FOLDER_QUOTING_CANONICAL_DOCTOR.sh`

## Status Summary

- `PROVEN`: The canonical hosted Proton MCP server path is `/home/openclaw/cornerstone-integrations/email_mcp_server.py`.
- `PROVEN`: The live hosted workspace `.mcp.json` points `proton-email` at `/home/openclaw/cornerstone-integrations/.venv/bin/python /home/openclaw/cornerstone-integrations/email_mcp_server.py`.
- `PROVEN`: The folder quoting fix is now applied in that canonical hosted file, not only in a temporary `/tmp` proof path.
- `PROVEN`: A rollback-grade backup was created before the edit:
  - `/home/openclaw/cornerstone-integrations/email_mcp_server.py.bak-20260317T202709Z`
- `PROVEN`: Safe live proof from the canonical hosted file path now succeeds for:
  - `list_messages(folder="All Mail")`
  - `read_message(uid=..., folder="All Mail")`
- `PROVEN`: `proton-bridge.service` remained `active` and the Docker container remained `healthy`.
- `PROVEN`: No send was attempted.
- `PROVEN`: Telegram services were untouched.

## What Changed

The canonical hosted file:

- `/home/openclaw/cornerstone-integrations/email_mcp_server.py`

now contains:

- `_quote_imap_mailbox(mailbox)`
- quoted mailbox handling in `list_mailboxes`
- quoted folder handling in `list_messages`
- quoted folder handling in `read_message`
- quoted folder handling in `stage_reply`

## Canonical Proof

### Canonical runtime registration

`PROVEN` from hosted workspace `claude mcp get proton-email`:

- `Scope: Project config (shared via .mcp.json)`
- `Status: ✓ Connected`

### Canonical file proof

`PROVEN` by executing the canonical hosted file through the hosted Proton venv with:

- target: `/home/openclaw/cornerstone-integrations/email_mcp_server.py`

Observed proof result:

- `mailboxes_has_all_mail=True`
- `list_ok=True`
- `list_error=False`
- `list_uid_present=True`
- `read_ok=True`
- `read_error=False`
- `send_attempted=False`

This is the operator-safe meaning:

- `All Mail` is visible
- `All Mail` can now be listed from the canonical hosted file
- a real message in `All Mail` can now be read from the canonical hosted file
- the previous IMAP `expected CR` failure is no longer present in this canonical path proof

## Historical vs Current

- `PROVEN`: Earlier evidence showed the bug fixed in a temporary `/tmp` path. That was useful proof-of-cause, but it was not the final hosted ownership surface.
- `PROVEN`: The current canonical hosted fix is in `/home/openclaw/cornerstone-integrations/email_mcp_server.py`.
- `PROVEN`: `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_MCP_PROOF.md` should now be read as historical for the old broken `All Mail` state.

## What is NOT PROVEN

- `NOT PROVEN`: End-to-end `claude -p` tool execution for this exact `All Mail` proof in this terminal.
- `NOT PROVEN`: `stage_reply(folder="All Mail")` was executed live after the patch. The code path is patched, but this note keeps the live proof read-only.
- `NOT PROVEN`: Any send flow. None was attempted.

## Operator Commands

Canonical read-only doctor:

```bash
bash /Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_FOLDER_QUOTING_CANONICAL_DOCTOR.sh
```

## Rollback

- restore from `/home/openclaw/cornerstone-integrations/email_mcp_server.py.bak-20260317T202709Z` if this patch must be reverted
- no Telegram ownership change is involved
- `cornerstone-telegram.service` remains live
- `openclaw-gateway.service` remains live
