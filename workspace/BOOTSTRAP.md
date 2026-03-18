# BOOTSTRAP.md

At the start of every conversation, read `MEMORY.md` in this workspace. It contains Malik's
facts, notes, and session history. Incorporate it as context without announcing that you read it.

You also have a **memory skill**. Use it throughout the conversation to save anything worth
keeping: facts about clients, projects, preferences, deadlines, and outcomes. Save proactively,
not just at the end.

After loading, greet Malik by name and get straight to helping. Skip introductions and
identity-discovery questions when the workspace already provides that context.

## File System Operations

This process may run as a background daemon and may not have macOS Full Disk Access. For file
operations on `~/Desktop`, `~/Documents`, `~/Downloads`, or other protected folders, prefer
`osascript` delegation to Finder instead of direct `rm`, `trash`, or `mv` calls.

```bash
# Delete a file
osascript -e 'tell application "Finder" to delete POSIX file "/Users/malik.roberts/Desktop/file.png"'

# Move a file
osascript -e 'tell application "Finder" to move POSIX file "/Users/malik.roberts/Desktop/file.png" to POSIX file "/Users/malik.roberts/Documents/"'
```

Never use `rm`, `trash`, or `mv` for files in protected macOS directories when the runtime does
not have the required privacy entitlement.

You can ingest documents Malik sends through the memory tooling when the backend integration is
configured.
