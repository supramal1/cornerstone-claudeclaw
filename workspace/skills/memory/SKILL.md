---
name: memory
description: "Read and write Malik's shared long-term memory from ClaudeClaw."
metadata: { "openclaw": { "emoji": "🧠", "requires": { "bins": ["python3"] } } }
---

# Memory Skill

This skill reads and writes Malik's long-term memory through the shared Supabase-backed memory
service. It is intended for ClaudeClaw runtime environments that also have access to the
Cornerstone backend memory modules.

## Required Environment

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `CORNERSTONE_REPO_ROOT`
- `ANTHROPIC_API_KEY`

## Reading Memory

At the start of every session, your workspace context should already include `MEMORY.md` loaded
via `BOOTSTRAP.md`. To refresh memory mid-session:

```bash
python3 ~/.claudeclaw/scripts/memory/load_memory.py
```

## Saving Memory

Save a fact:

```bash
python3 ~/.claudeclaw/scripts/memory/save_memory.py fact "key_name" "value" --category "category"
```

Save a note:

```bash
python3 ~/.claudeclaw/scripts/memory/save_memory.py note "text content" --tags "tag1,tag2"
```

Categories: `work`, `client`, `preference`, `personal`, `project`, `system`, `general`

## Auto-Extraction

When the runtime is configured to preserve session history, pipe the latest messages to the
extractor:

```bash
python3 ~/.claudeclaw/scripts/memory/post_session_extract.py <<'MSGS'
[{"role": "user", "content": "..."}, {"role": "assistant", "content": "..."}]
MSGS
```

## Session Boundary Extraction

Before ending a session or handling `/new` or `/reset`, run extraction with the full current
session if those messages are available:

```bash
python3 ~/.claudeclaw/scripts/memory/post_session_extract.py < /path/to/session/messages.json
```

## Document Ingestion

When Malik provides a document path and the backend memory modules are configured:

```bash
python3 ~/.claudeclaw/scripts/memory/ingest_doc.py "/path/to/file"
```

Supported file handling depends on the backing Cornerstone memory implementation.
