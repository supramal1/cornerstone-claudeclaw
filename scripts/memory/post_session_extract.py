#!/usr/bin/env python3
"""Extract structured facts and notes from recent ClaudeClaw messages."""

import json
import os
import sys

from dotenv import load_dotenv


def resolve_backend_root() -> str:
    repo_root = os.environ.get("CORNERSTONE_REPO_ROOT")
    if not repo_root:
        raise RuntimeError("CORNERSTONE_REPO_ROOT is required")
    return os.path.abspath(os.path.expanduser(repo_root))


def main() -> int:
    backend_root = resolve_backend_root()
    sys.path.insert(0, backend_root)
    load_dotenv(os.path.join(backend_root, ".env"))

    try:
        messages = json.load(sys.stdin)
    except Exception:
        return 0

    if not messages or len(messages) < 2:
        return 0

    try:
        import anthropic
        from src.memory.facts import add_fact
        from src.memory.notes import add_note

        recent = messages[-8:]
        recent_text = "\n".join(f"{msg['role'].upper()}: {msg['content']}" for msg in recent)

        prompt = (
            "Review these conversation messages. If any new facts, decisions, client names, "
            "preferences, or project details were mentioned that should be remembered, return JSON: "
            '{"facts": [{"key": "snake_case", "value": "value", "category": "general", "confidence": 0.75}]}. '
            'Optionally include {"notes": [{"content": "text", "tags": ["tag"]}]}. '
            'Only include clearly stated facts or notes. If nothing important, return {"facts": [], "notes": []}. '
            "Return ONLY JSON, no other text."
        )

        client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
        response = client.messages.create(
            model="claude-haiku-4-5-20251001",
            max_tokens=1024,
            messages=[{"role": "user", "content": f"{prompt}\n\n{recent_text}"}],
        )

        payload = response.content[0].text.strip()
        if payload.startswith("```"):
            payload = payload.split("\n", 1)[1].rsplit("```", 1)[0].strip()

        data = json.loads(payload)

        facts_saved = 0
        for fact in data.get("facts", []):
            if fact.get("key") and fact.get("value"):
                add_fact(
                    fact["key"],
                    fact["value"],
                    fact.get("category", "general"),
                    source="claudeclaw_session",
                    confidence=fact.get("confidence", 0.75),
                )
                facts_saved += 1

        notes_saved = 0
        for note in data.get("notes", []):
            if note.get("content"):
                add_note(
                    note["content"],
                    tags=note.get("tags", ["claudeclaw"]),
                    source="claudeclaw_session",
                )
                notes_saved += 1

        if facts_saved > 0 or notes_saved > 0:
            print(f"Extracted: {facts_saved} facts, {notes_saved} notes")
    except Exception:
        pass

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
