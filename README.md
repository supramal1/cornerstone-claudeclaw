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

## Key Docs

- [ROADMAP_STATUS.md](ROADMAP_STATUS.md) — Current priorities and sprint status
- [REPO_ARCHITECTURE_STATUS.md](REPO_ARCHITECTURE_STATUS.md) — Repo split verdict

## Migration Status

Migration from `openclaw` is effectively complete. See REPO_ARCHITECTURE_STATUS.md for details.
