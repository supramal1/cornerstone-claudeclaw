#!/usr/bin/env python3
"""Write facts or notes to Supabase for ClaudeClaw."""

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone


def require_env(name: str) -> str:
    value = os.environ.get(name)
    if value:
        return value
    print(f"Missing required environment variable: {name}", file=sys.stderr)
    raise SystemExit(1)


SUPABASE_URL = require_env("SUPABASE_URL")
SUPABASE_KEY = require_env("SUPABASE_PUBLISHABLE_KEY")
HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates,return=representation",
}


def post(table: str, payload: dict) -> dict:
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    data = json.dumps(payload).encode()
    request = urllib.request.Request(url, data=data, headers=HEADERS, method="POST")
    try:
        with urllib.request.urlopen(request, timeout=8) as response:
            result = json.loads(response.read())
            return result[0] if isinstance(result, list) and result else result
    except urllib.error.HTTPError as exc:
        body = exc.read().decode()
        print(f"Error {exc.code}: {body}", file=sys.stderr)
        raise SystemExit(1)


def save_fact(key: str, value: str, category: str = "general") -> None:
    now = datetime.now(timezone.utc).isoformat()
    record = {
        "key": key.lower().replace(" ", "_"),
        "value": value,
        "category": category,
        "source": "claudeclaw",
        "confidence": 0.9,
        "updated_at": now,
    }
    post("facts", record)
    print(f"Saved fact: {record['key']} = {value}")


def save_note(content: str, tags: list[str] | None = None) -> None:
    record = {
        "content": content,
        "tags": tags or [],
        "source": "claudeclaw",
    }
    post("notes", record)
    tag_str = f" [{', '.join(tags)}]" if tags else ""
    suffix = "..." if len(content) > 80 else ""
    print(f"Saved note{tag_str}: {content[:80]}{suffix}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Save memory to Supabase")
    subcommands = parser.add_subparsers(dest="command", required=True)

    fact_parser = subcommands.add_parser("fact", help="Save a fact")
    fact_parser.add_argument("key", help="Fact key")
    fact_parser.add_argument("value", help="Fact value")
    fact_parser.add_argument("--category", default="general")

    note_parser = subcommands.add_parser("note", help="Save a note")
    note_parser.add_argument("content", help="Note text")
    note_parser.add_argument("--tags", default="", help="Comma-separated tags")

    args = parser.parse_args()

    if args.command == "fact":
        save_fact(args.key, args.value, args.category)
        return 0

    tags = [tag.strip() for tag in args.tags.split(",") if tag.strip()] if args.tags else []
    save_note(args.content, tags)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
