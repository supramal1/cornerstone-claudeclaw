#!/usr/bin/env python3
from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import shutil
import sys


TARGET = Path("/home/openclaw/cornerstone-integrations/email_mcp_server.py")
HELPER_SIGNATURE = "def _quote_imap_mailbox(mailbox: str) -> str:"
IMAP_HELPER_ANCHOR = (
    "# ---------------------------------------------------------------------------\n"
    "# IMAP helpers\n"
    "# ---------------------------------------------------------------------------\n\n"
)
HELPER_BLOCK = (
    "def _quote_imap_mailbox(mailbox: str) -> str:\n"
    '    """Return an IMAP-safe quoted mailbox name."""\n'
    "    value = str(mailbox).strip()\n"
    '    escaped = value.replace("\\\\", "\\\\\\\\").replace(\'"\', \'\\\\"\')\n'
    '    return f\'"{escaped}"\'\n'
    "\n\n"
)

REPLACEMENTS = {
    'conn.status(f\'"{folder_name}"\', "(MESSAGES UNSEEN)")':
        'conn.status(_quote_imap_mailbox(folder_name), "(MESSAGES UNSEEN)")',
    "conn.select(folder, readonly=True)":
        "conn.select(_quote_imap_mailbox(folder), readonly=True)",
}


def main() -> int:
    if not TARGET.exists():
        print(f"missing target: {TARGET}", file=sys.stderr)
        return 1

    original = TARGET.read_text()
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup = TARGET.with_name(TARGET.name + f".bak-{ts}")
    shutil.copy2(TARGET, backup)

    updated = original
    if HELPER_SIGNATURE not in updated:
        if IMAP_HELPER_ANCHOR not in updated:
            print("missing IMAP helper anchor", file=sys.stderr)
            return 1
        updated = updated.replace(IMAP_HELPER_ANCHOR, IMAP_HELPER_ANCHOR + HELPER_BLOCK, 1)

    for old, new in REPLACEMENTS.items():
        if old not in updated:
            print(f"missing expected pattern: {old}", file=sys.stderr)
            return 1
        updated = updated.replace(old, new)

    TARGET.write_text(updated)

    print(f"backup={backup}")
    print(f"target={TARGET}")
    print("helper_present=" + str(HELPER_SIGNATURE in updated))
    print(
        "status_call_count="
        + str(updated.count('conn.status(_quote_imap_mailbox(folder_name), "(MESSAGES UNSEEN)")'))
    )
    print(
        "select_call_count="
        + str(updated.count("conn.select(_quote_imap_mailbox(folder), readonly=True)"))
    )
    print(
        "raw_status_remaining="
        + str('conn.status(f\'"{folder_name}"\', "(MESSAGES UNSEEN)")' in updated)
    )
    print("raw_select_remaining=" + str("conn.select(folder, readonly=True)" in updated))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
