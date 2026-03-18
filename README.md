# cornerstone-claudeclaw

ClaudeClaw runtime repo.

This repo is the clean Git home for the ClaudeClaw runtime and hosted operator surface.

What belongs here:
- ClaudeClaw runtime source code
- Telegram and operator-facing runtime code
- Hosted runtime scripts and templates that are safe to version
- ClaudeClaw-specific docs and runbooks that travel with the runtime

What does not belong here:
- Cornerstone backend code and backend-only docs
- Cornerstone integrations/connectors code
- `.env` files or rendered token-bearing settings
- VM backups, logs, plugin caches, or other machine-local runtime state

Current stack split:
- `cornerstone`: backend, proofs, and backend-adjacent operator work
- `cornerstone-integrations`: MCP/connectors and integration proofs
- `cornerstone-claudeclaw`: runtime repo to populate intentionally next

Suggested next migration scope:
1. Move tracked runtime code from the old local `openclaw` repo into this repo.
2. Bring over only repo-safe hosted scripts and docs.
3. Keep VM runtime state out of git.
