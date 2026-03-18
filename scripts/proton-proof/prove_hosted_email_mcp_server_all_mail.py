#!/usr/bin/env python3
from __future__ import annotations

import asyncio
import importlib.util
from pathlib import Path
import sys


TARGET = Path("/home/openclaw/cornerstone-integrations/email_mcp_server.py")


def _load_module():
    spec = importlib.util.spec_from_file_location("hosted_email_mcp_server", TARGET)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"could not load spec for {TARGET}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _text_of(items) -> str:
    parts = []
    for item in items:
        text = getattr(item, "text", None)
        if text is not None:
            parts.append(text)
    return "\n".join(parts)


async def _main() -> int:
    mod = _load_module()
    mailboxes = _text_of(await mod.call_tool("list_mailboxes", {}))
    listing = _text_of(
        await mod.call_tool(
            "list_messages",
            {"folder": "All Mail", "query": "", "max_results": 3},
        )
    )

    uid = None
    for line in listing.splitlines():
        if line.startswith("[") and "]" in line:
            uid = line[1 : line.index("]")].strip()
            break

    print("target=" + str(TARGET))
    print("mailboxes_has_all_mail=" + str("All Mail" in mailboxes))
    print("list_ok=" + str("Found " in listing or "No messages" in listing))
    print(
        "list_error="
        + str(
            "Could not open folder" in listing
            or "Error:" in listing
            or "expected CR" in listing
        )
    )
    print("list_uid_present=" + str(bool(uid)))

    if uid:
        read_out = _text_of(await mod.call_tool("read_message", {"uid": uid, "folder": "All Mail"}))
        print("read_ok=" + str("Subject:" in read_out and "From:" in read_out))
        print(
            "read_error="
            + str(
                "Could not open folder" in read_out
                or "Error:" in read_out
                or "expected CR" in read_out
            )
        )
        print("read_uid=" + uid)
    else:
        print("read_ok=False")
        print("read_error=False")
        print("read_uid=")

    print("send_attempted=False")

    if "All Mail" not in mailboxes:
        return 1
    if not ("Found " in listing or "No messages" in listing):
        return 1
    if "Could not open folder" in listing or "Error:" in listing or "expected CR" in listing:
        return 1
    if uid:
        if not ("Subject:" in read_out and "From:" in read_out):
            return 1
        if "Could not open folder" in read_out or "Error:" in read_out or "expected CR" in read_out:
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(asyncio.run(_main()))
