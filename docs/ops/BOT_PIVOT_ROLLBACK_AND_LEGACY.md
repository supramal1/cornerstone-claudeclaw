# BOT_PIVOT_ROLLBACK_AND_LEGACY

Last reviewed: 2026-03-17 23:05 UTC

## Status Summary

The intended canonical bot after convergence is now `@open_claudebot` (`8229279102`), and the live hosted ClaudeClaw path currently matches that identity.

At the same time, the legacy Telegram unit `cornerstone-telegram.service` is still `active/running` and still points to `@openclawlobbybot` (`8375038775`), so the overall system is not yet in a clean single-owner operator state.

Rollback is still possible, but "rollback" now needs to be stated precisely:

- bot-pivot rollback of hosted ClaudeClaw would restore the hosted bot identity from `@open_claudebot` back to `@openclawlobbybot`
- the legacy Telegram unit already remains on `@openclawlobbybot`
- the fallback gateway remains live and unchanged

## What is PROVEN

- `claudeclaw-hosted.service` is `active/running` with:
  - `MainPID=79360`
  - `ExecMainStartTimestamp=Tue 2026-03-17 23:05:09 UTC`
  - `WorkingDirectory=/home/openclaw/claudeclaw/theclaw`
  - `ExecStart=/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.sh`
- `cornerstone-telegram.service` is `active/running` with:
  - `MainPID=812`
  - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
  - `WorkingDirectory=/home/openclaw/cornerstone`
  - `ExecStart=/home/openclaw/cornerstone/.venv/bin/python main.py telegram`
- `openclaw-gateway.service` is `active/running` with:
  - `MainPID=807`
  - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
- The live hosted runtime settings file `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json` currently resolves to:
  - bot ID `8229279102`
  - `allowedUserIds=[7807161252]`
- The live hosted Telegram env file `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env` currently resolves to:
  - bot ID `8229279102`
  - allowed user `7807161252`
- The hosted journal for `claudeclaw-hosted.service` at `2026-03-17 23:05:10 UTC` logged:
  - `Telegram: enabled`
  - `Bot: @open_claudebot`
  - `Telegram bot started (long polling)`
  - `Allowed users: 7807161252`
- The legacy unit token source `/home/openclaw/cornerstone/.env` currently resolves to:
  - bot ID `8375038775`
  - allowed user `7807161252`
- The legacy journal still shows a live polling conflict for that unit:
  - `telegram.error.Conflict: Conflict: terminated by other getUpdates request; make sure that only one bot instance is running`
- The preserved pre-ClaudeClaw rollback anchor exists at:
  - `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/`
- The preserved rollback-anchor file `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/env/malik-cornerstone.env` resolves to:
  - bot ID `8375038775`
  - `TELEGRAM_ALLOWED_USER_ID=7807161252`
- The fresh bot-pivot backup dir exists at:
  - `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/`
- That fresh bot-pivot backup currently resolves to legacy bot state in both files:
  - `claudeclaw-telegram.env.backup` -> bot ID `8375038775`
  - `settings.json.backup` -> bot ID `8375038775`
- The older cutover backup dir still exists at:
  - `/home/openclaw/claudeclaw-backups/20260317T204819Z-cutover/`
- `BOT_IDENTITY_PIVOT_EXECUTION.md` records the successful canonical hosted pivot to `@open_claudebot` at lines `7-23`, `59-99`, and `161-167`.

## What is INFERRED

- The cleanest bot-pivot rollback for hosted ClaudeClaw is now the fresh hosted backup at `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/`, because it was created immediately before the successful `23:05` pivot and both backed-up files still resolve to `8375038775`.
- If operators need to restore the legacy Telegram path itself, the legacy unit is still anchored on `/home/openclaw/cornerstone/.env`, and the older snapshot `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/env/malik-cornerstone.env` remains a preserved fallback source for the same legacy bot identity.
- The operator-safe rule should now be binary:
  - normal converged state: `@open_claudebot`
  - declared rollback state: `@openclawlobbybot`
- Any rollback note that says "copy the production token from the hosted env into the legacy unit" is now ambiguous or wrong, because the hosted env is no longer the legacy bot.

## What is NOT PROVEN

- This pass did not prove end-to-end Telegram receive/reply behavior for a fresh message to `@open_claudebot`.
- This pass did not prove long-term soak stability after the `2026-03-17 23:05 UTC` pivot.
- This pass did not prove whether `cornerstone-telegram.service` should later be stopped, disabled, or repointed; it only proved that it is still running and still on `@openclawlobbybot`.
- This pass did not mutate anything, so it did not execute the rollback procedure; it only proved which files and services that rollback would act on.

## Canonical bot after convergence

`@open_claudebot` (`8229279102`)

Canonical owner path:

- unit: `claudeclaw-hosted.service`
- hosted env: `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
- rendered runtime settings: `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`

## Legacy bot after convergence

`@openclawlobbybot` (`8375038775`)

Legacy paths still present:

- legacy unit: `cornerstone-telegram.service`
- legacy env source: `/home/openclaw/cornerstone/.env`
- preserved legacy snapshot: `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/env/malik-cornerstone.env`

## Rollback posture

Rollback should now be described in two layers, because both exist and they are not the same thing.

1. Hosted bot-pivot rollback
   - Purpose: revert hosted ClaudeClaw from canonical `@open_claudebot` back to legacy `@openclawlobbybot`.
   - Proven restore source:
     - `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/claudeclaw-telegram.env.backup`
     - `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/settings.json.backup`
   - Proven restored identity from those backups: `8375038775` / `@openclawlobbybot`

2. Legacy-unit rollback posture
   - Purpose: preserve or reassert the old legacy Telegram path if operators need the Python bot path.
   - Proven legacy unit: `cornerstone-telegram.service`
   - Proven legacy token source now: `/home/openclaw/cornerstone/.env`
   - Proven preserved fallback source: `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/env/malik-cornerstone.env`
   - Proven identity from both legacy sources: `8375038775` / `@openclawlobbybot`

Fallback posture:

- `openclaw-gateway.service` remains `active/running`
- this pass found no evidence that the fallback gateway needs to be part of bot-identity rollback
- rollback wording should therefore say the fallback gateway remains live unless a separate incident requires otherwise

Operator takeaway:

- normal post-convergence target: `@open_claudebot`
- declared rollback target: `@openclawlobbybot`
- do not describe rollback as if it preserves `@open_claudebot`
- do not describe `@openclawlobbybot` as the normal production default anymore

## Exact stale surfaces that still need updating

These surfaces still contain wording that treats `@openclawlobbybot` as the current hosted default, treats the pivot as incomplete, or describes rollback with the wrong token source.

- `HOSTED_OPERATOR_START_HERE.md`
  - lines `12-20`
  - lines `24-33`
  - lines `67-103`
  - Problem: still says the live hosted identity is `@openclawlobbybot`, still says no proof for `@open_claudebot`, and still frames rollback around the pre-pivot mismatch state.
- `HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`
  - lines `16-23`
  - lines `37-68`
  - lines `72-88`
  - Problem: still says the live hosted bot is `@openclawlobbybot` and that `@open_claudebot` ownership is not proven.
- `BOT_PIVOT_OPERATOR_STATUS.md`
  - lines `7-15`
  - lines `24-47`
  - lines `49-61`
  - Problem: still says the live hosted bot is `@openclawlobbybot`, still says the pivot artifacts were missing, and still treats the state as unresolved.
- `BOT_IDENTITY_TRUTH.md`
  - lines `7-16`
  - lines `27-57`
  - lines `59-65`
  - Problem: still treats `@openclawlobbybot` as the live hosted truth and still tells operators to test that bot next.
- `BOT_IDENTITY_DEMOTION_AND_ROLLBACK.md`
  - lines `7-16`
  - lines `43-54`
  - Problem: useful conceptually, but now stale on live-state facts because it still says the hosted path currently resolves to `@openclawlobbybot`.
- `CLAUDECLAW_HOSTED_TELEGRAM_ROLLBACK_EXECUTION_SHEET.md`
  - lines `18-33`
  - lines `41-45`
  - Problem: says rollback should extract the "production token" from the current hosted env, but the current hosted env is now canonical `@open_claudebot`, not legacy `@openclawlobbybot`.
  - Problem: the alternative restore path references `cornerstone-env.backup`, but the proven contents of `/home/openclaw/claudeclaw-backups/20260317T204819Z-cutover/` do not include that file.
- `CUTOVER_WINDOW_AUTHORIZED.env`
  - lines `3-6`
  - Problem: still declares `openclawlobbybot` as `TARGET_PRODUCTION_BOT_*` and `open_claudebot` as `HOSTED_SMOKE_BOT_*`.
- `POST_CUTOVER_ROLLBACK_READINESS.md`
  - lines `5`
  - lines `13-16`
  - lines `54-89`
  - lines `147-170`
  - Problem: still treats `@openclawlobbybot` as the active hosted production bot and frames rollback around that older cutover state.
- `CUTOVER_EXECUTION_LOG.md`
  - lines `11-14`
  - lines `56-64`
  - lines `125-130`
  - Problem: valid as historical evidence, but stale as current operator truth because it still names `@openclawlobbybot` as the production bot.

## Recommended operator wording

Use wording materially equivalent to this in the main start-here surface and the rollback sheet:

```md
Canonical Telegram bot after the 2026-03-17 hosted bot-identity convergence is `@open_claudebot` (`8229279102`).
Legacy Telegram bot is `@openclawlobbybot` (`8375038775`).

If bot-identity rollback is declared, hosted ClaudeClaw rollback restores `@openclawlobbybot` from the fresh pre-pivot hosted backups, not from the current hosted env.
If operators need the legacy Python bot path, `cornerstone-telegram.service` and `/home/openclaw/cornerstone/.env` remain the legacy bot path and still resolve to `@openclawlobbybot`.

Normal smoke target: `@open_claudebot`
Declared rollback target: `@openclawlobbybot`
Fallback gateway posture: keep `openclaw-gateway.service` live unless a separate incident requires otherwise.
```
