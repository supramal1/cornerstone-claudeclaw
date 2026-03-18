---
name: supabase-extract
description: "Run post-session memory extraction on /new, /reset, or /stop"
metadata:
  {
    "openclaw":
      {
        "emoji": "🧠",
        "events": ["command:new", "command:reset", "command:stop"],
      },
  }
---

# Supabase Extract Hook

Runs the ClaudeClaw post-session extraction script whenever a session ends via `/new`,
`/reset`, or `/stop`.

## What It Does

When any of those commands are issued, this hook calls the local extractor script:

```bash
${CLAUDECLAW_MEMORY_PYTHON:-python3} ${CLAUDECLAW_HOME:-$HOME/.claudeclaw}/scripts/memory/post_session_extract.py
```

If the hook payload includes a `messages` array, the handler forwards that JSON to stdin so
the extractor can persist the latest session facts and notes.

## Behaviour

- Runs silently in the background
- If the script fails or is not present, the hook exits cleanly without disrupting the command
- No user notification; memory confirmation stays in the runtime flow

## Environment Overrides

- `CLAUDECLAW_HOME`
  Defaults to `$HOME/.claudeclaw`
- `CLAUDECLAW_MEMORY_PYTHON`
  Defaults to `python3`
- `CLAUDECLAW_POST_SESSION_EXTRACT`
  Override the extractor path directly when needed

## Disabling

```bash
openclaw hooks disable supabase-extract
```
