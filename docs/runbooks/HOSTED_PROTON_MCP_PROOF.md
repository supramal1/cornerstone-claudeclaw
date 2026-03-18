# Hosted Proton MCP Proof

Date: `2026-03-17`

Scope:

- hosted VM only: `openclaw-vm`
- Proton Bridge / Proton email MCP inspection and proof
- no external send
- no Telegram changes

## Status

- `PROVEN`: The old `All Mail` folder quoting defect described later in this note has been fixed in the canonical hosted file `/home/openclaw/cornerstone-integrations/email_mcp_server.py`.
- `PROVEN`: For the current post-fix operator state, use `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_FOLDER_QUOTING_CANONICALIZATION.md`.
- `PROVEN`: This file remains useful for the broader Proton MCP surface proof, but the old pre-fix `All Mail` failure sections are now historical.
- PROVEN: Hosted ClaudeClaw sees a Proton-related MCP server named `proton-email`.
- PROVEN: Hosted ClaudeClaw exposes six Proton email MCP tools.
- PROVEN: Proton Bridge infra is healthy on the VM and bound to loopback only.
- PROVEN: The hosted Proton email MCP backend can authenticate, list mailboxes, list messages from a non-empty mailbox, and read a message body.
- PROVEN: The current hosted path is useful for read-oriented email assistant work.
- PROVEN: Write tools are exposed and `PROTON_WRITE_ENABLED` resolves `true`.
- NOT PROVEN: end-to-end Claude CLI tool execution via `claude -p` returned promptly in this session; direct server execution under the hosted venv was used for the mailbox/list/read proof.
- NOT PROVEN: safe self-addressed send/readback. It was not attempted.

## Exact MCP Surface

### Hosted MCP registration

From the hosted Claude workspace `/home/openclaw/claudeclaw/theclaw`:

```text
proton-email: /home/openclaw/cornerstone-integrations/.venv/bin/python /home/openclaw/cornerstone-integrations/email_mcp_server.py - ✓ Connected
```

PROVEN server path:

- `/home/openclaw/cornerstone-integrations/email_mcp_server.py`

### Exact tool names visible to hosted Claude

PROVEN via hosted `claude -p` tool enumeration:

- `mcp__proton-email__confirm_send`
- `mcp__proton-email__list_mailboxes`
- `mcp__proton-email__list_messages`
- `mcp__proton-email__read_message`
- `mcp__proton-email__stage_email`
- `mcp__proton-email__stage_reply`

### Tool contract from server code

PROVEN from `/home/openclaw/cornerstone-integrations/email_mcp_server.py`:

- read tools:
  - `list_mailboxes`
  - `list_messages`
  - `read_message`
- write tools:
  - `stage_email`
  - `stage_reply`
  - `confirm_send`

The server docstring states:

- IMAP endpoint: `127.0.0.1:1143`
- SMTP endpoint: `127.0.0.1:1025`
- env source: `/home/openclaw/cornerstone/.env`

## Proton Bridge Infra Proof

### Service and container

PROVEN:

- `proton-bridge.service` is `active (running)`
- service unit path: `/home/openclaw/.config/systemd/user/proton-bridge.service`
- active since: `Tue 2026-03-17 12:24:17 UTC`
- Docker container: `proton-bridge`
- container image: `proton-bridge:current`
- Docker health: `healthy`

### Loopback ports

PROVEN:

- `127.0.0.1:1143` listening
- `127.0.0.1:1025` listening

These match the server’s resolved config:

```json
{
  "proton_host": "127.0.0.1",
  "imap_port": 1143,
  "smtp_port": 1025,
  "write_enabled": true,
  "config_ok": true
}
```

### Env/config surfaces present by name

PROVEN in `/home/openclaw/cornerstone/.env`:

- `PROTON_EMAIL`
- `PROTON_BRIDGE_PASSWORD`
- `PROTON_HOST`
- `PROTON_IMAP_PORT`
- `PROTON_SMTP_PORT`
- `PROTON_READ_ENABLED`
- `PROTON_WRITE_ENABLED`

No secret values are reproduced here.

## Read/Status Proof

### Account/status visibility

PROVEN by successful `list_mailboxes` call through the hosted Proton MCP server.

Observed mailbox output included counts for:

- `Archive — 5783 messages (2270 unread)`
- `All Mail — 6234 messages (2531 unread)`
- `INBOX — 0 messages (0 unread)`
- `Sent — 66 messages (0 unread)`
- `Drafts — 28 messages (0 unread)`
- `Spam — 231 messages (231 unread)`

This proves:

- Proton Bridge IMAP auth succeeded
- mailbox enumeration succeeded
- per-folder counts are available
- the hosted path is reading live account state, not just reporting “connected”

### Safe list capability

PROVEN by successful `list_messages(folder='Archive', max_results=3)` through the hosted Proton MCP server.

Observed result:

- `Found 3 message(s) in Archive`
- message UIDs returned:
  - `5783`
  - `5782`
  - `5781`

For all three returned messages:

- `From` present
- `Subject` present
- `Date` present

Raw sender and subject strings were observed in the operator terminal but are intentionally not reproduced here.

### Safe read capability

PROVEN by successful `read_message(uid='5783', folder='Archive')` through the hosted Proton MCP server.

Observed summary:

```json
{
  "id": "5783",
  "has_from": true,
  "has_to": true,
  "has_subject": true,
  "has_date": true,
  "body_non_empty": true,
  "body_length_bucket": ">1000"
}
```

This proves the hosted Proton MCP path can fetch and parse full message content, not just headers.

## Connected vs Useful

### Only CONNECTED would mean

- MCP server appears in `claude mcp list`
- Bridge container is healthy
- but mailbox operations are not proven

### PROVEN useful means

The hosted path now has evidence for:

- mailbox listing
- message listing
- message read
- live mailbox counts
- real parsed message body access

Conclusion:

- PROVEN: the hosted path is genuinely useful for read-oriented email assistant work.

## Send/Write Boundary

### What is live

PROVEN:

- `mcp__proton-email__stage_email`
- `mcp__proton-email__stage_reply`
- `mcp__proton-email__confirm_send`
- `PROTON_WRITE_ENABLED` resolves `true`

### What was not done

No send was attempted.

Reason:

- the task allowed send only to the operator’s own Proton account
- proving the safe target would require using private account identity not needed for read/status proof
- read usefulness was already proven without crossing the send boundary

## Drift / Unsafe Assumptions

### Folder-name bug

Historical note:

- `PROVEN`: The failure described in this section was true before the canonical hosted fix landed.
- `PROVEN`: It is no longer the current operator truth after `/home/openclaw/cornerstone-integrations/email_mcp_server.py` was patched.
- `PROVEN`: Read `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_FOLDER_QUOTING_CANONICALIZATION.md` for the current post-fix state.

PROVEN:

`list_messages(folder='All Mail')` currently fails with:

```text
Error: abort: command: EXAMINE => unexpected response: b' BAD [Error offset=17]: expected CR'
```

This strongly suggests folder names with spaces are not being quoted correctly when passed to IMAP `select`.

Impact:

- `All Mail` is visible in `list_mailboxes`
- but not currently usable in `list_messages` / likely `read_message` if the same folder-name handling is used

### Claude CLI invocation gap

PROVEN:

- hosted Claude enumerated the Proton tool names
- direct hosted MCP-server execution proved mailbox/list/read behavior

NOT PROVEN in this session:

- a `claude -p` session completed an actual Proton tool call and returned promptly

This is a proof gap in the CLI conversation loop, not in the Proton Bridge backend itself.

### Linger check caveat

`bridge-check.sh` reported:

- `linger NOT enabled for malik_roberts_gmail_com`

This is not authoritative for the `openclaw` service user when the script is run via a different SSH identity. It should not be treated as proof that the `openclaw` user’s linger state is wrong.

## Minimal Next Patch

Historical note:

- `PROVEN`: This section is superseded. The minimal patch described here has now been applied in the canonical hosted file.

Necessary patch:

- quote IMAP folder names consistently in `/home/openclaw/cornerstone-integrations/email_mcp_server.py` for:
  - `list_messages`
  - `read_message`
  - `stage_reply`

Why this is the minimum:

- Bridge health is already good
- mailbox and read flows already work
- the concrete functional defect found is mailbox selection for names containing spaces such as `All Mail`

Optional hardening later, but not required for read usefulness:

- disable write tools until send is explicitly approved, if the hosted runtime should remain read-only for now

## Verdict

Historical note:

- `PROVEN`: The "NOT YET CLEAN" wording below is superseded for the `All Mail` quoting defect.
- `PROVEN`: Current operator truth is tracked in `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/HOSTED_PROTON_FOLDER_QUOTING_CANONICALIZATION.md`.

- PROVEN: `proton-email` is not merely connected; it supports real mailbox and message-read workflows on the hosted runtime.
- PROVEN: the hosted path is useful today for read-oriented assistant email work.
- NOT YET CLEAN: the folder-name handling bug means some high-value folders such as `All Mail` are exposed but not fully usable.
