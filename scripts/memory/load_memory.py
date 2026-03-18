#!/usr/bin/env python3
"""Fetch memory context from Supabase for ClaudeClaw."""

import os
import sys


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if value:
        return value
    print(f"Missing required environment variable: {name}", file=sys.stderr)
    raise SystemExit(1)


SUPABASE_URL = require_env("SUPABASE_URL")
SUPABASE_KEY = require_env("SUPABASE_PUBLISHABLE_KEY")

try:
    from supabase import create_client
except ImportError:
    import json
    import urllib.request

    headers = {"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}"}

    def fetch(table: str, select: str = "*", limit: int = 20, order: str | None = None):
        url = f"{SUPABASE_URL}/rest/v1/{table}?select={select}&limit={limit}"
        if order:
            url += f"&order={order}"
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=5) as response:
            return json.loads(response.read())

    facts = fetch("facts", select="key,value,category", limit=50)
    notes = fetch("notes", select="content,tags,created_at", limit=10, order="created_at.desc")
    sessions = fetch("sessions", select="topic,summary,started_at", limit=5, order="started_at.desc")
else:
    db = create_client(SUPABASE_URL, SUPABASE_KEY)
    facts = db.table("facts").select("key,value,category").limit(50).execute().data or []
    notes = db.table("notes").select("content,tags,created_at").order(
        "created_at", desc=True
    ).limit(10).execute().data or []
    sessions = db.table("sessions").select("topic,summary,started_at").order(
        "started_at", desc=True
    ).limit(5).execute().data or []

output: list[str] = []

if facts:
    output.append("## Facts about Malik")
    for fact in facts:
        output.append(f"- **{fact['key']}**: {fact['value']}")

if notes:
    output.append("\n## Recent Notes")
    for note in notes:
        tags = ", ".join(note.get("tags") or [])
        tag_str = f" [{tags}]" if tags else ""
        output.append(f"- {note['content'][:200]}{tag_str}")

if sessions:
    output.append("\n## Recent Sessions")
    for session in sessions:
        topic = session.get("topic") or "untitled"
        summary = session.get("summary") or ""
        if summary:
            output.append(f"- **{topic}**: {summary[:150]}")
        else:
            output.append(f"- {topic}")

print("\n".join(output) if output else "No memory yet.")
