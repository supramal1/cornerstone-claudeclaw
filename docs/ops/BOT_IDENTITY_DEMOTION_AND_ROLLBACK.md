# BOT_IDENTITY_DEMOTION_AND_ROLLBACK

Last reviewed: 2026-03-17 22:51 UTC

## Status Summary

As of `2026-03-17 22:51 UTC`, the live hosted Telegram configuration still resolves to `@openclawlobbybot` (`8375038775`), not `@open_claudebot` (`8229279102`).
The hosted service journal also re-announced `Bot: @openclawlobbybot` at `2026-03-17 22:51:03 UTC`.
At the same time, both `claudeclaw-hosted.service` and `cornerstone-telegram.service` are `active/running`, so the current live system is not a clean single-owner post-pivot state.

This note makes the intended post-pivot rule explicit:

- After the pivot, `@open_claudebot` is canonical.
- After the pivot, `@openclawlobbybot` is legacy.
- If rollback is declared, rollback restores `@openclawlobbybot` as the single Telegram production owner until a new pivot attempt is approved.
- Rollback must not leave both bots or both Telegram pollers looking "sort of canonical" at the same time.

## What is PROVEN

- Live VM state on `2026-03-17 22:51:01 UTC` showed all three units `active/running`:
  - `claudeclaw-hosted.service`
  - `cornerstone-telegram.service`
  - `openclaw-gateway.service`
- The hosted runtime settings file at `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json` currently resolves to bot ID `8375038775` and allowed user `[7807161252]`.
- The hosted Telegram env file at `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env` currently resolves to bot ID `8375038775` and allowed user `7807161252`.
- The hosted journal for `claudeclaw-hosted.service` logged:
  - `Telegram: enabled`
  - `Bot: @openclawlobbybot`
  - `Telegram bot started (long polling)`
  - `Allowed users: 7807161252`
- The preserved rollback anchor exists at `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/`.
- The preserved rollback anchor file `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/env/malik-cornerstone.env` contains:
  - `TELEGRAM_BOT_TOKEN=8375038775:...`
  - `TELEGRAM_ALLOWED_USER_ID=7807161252`
- The cutover backup directory exists at `/home/openclaw/claudeclaw-backups/20260317T204819Z-cutover/` and contains:
  - `claudeclaw-telegram.env.backup`
  - `settings.json.backup`
  - `claudeclaw-hosted.sh.backup`
  - `render-hosted-telegram-settings.sh.backup`

## What is INFERRED

- The intended next canonical identity is still `@open_claudebot` because that is the sprint brief and the explicit "intended new canonical" target for this task.
- `@openclawlobbybot` is the bot that rollback would need to restore, because both the current hosted config and the preserved rollback anchor still resolve to `8375038775`.
- The safest rollback posture for a future bot pivot is a fresh pre-pivot snapshot of the hosted bot files while they still resolve to `@openclawlobbybot`, even though the older anchor already preserves a legacy restore path for that same bot.
- The clean operator rule after pivot should be binary:
  - normal operation: `@open_claudebot` only
  - declared rollback: `@openclawlobbybot` only

## What is NOT PROVEN

- No live evidence in this pass proves that `@open_claudebot` is already bound to the hosted runtime.
- No live evidence in this pass proves that a dedicated pre-pivot hosted snapshot for the `@open_claudebot` swap has already been captured.
- No live evidence in this pass proves that the new bot pivot has passed a clean single-owner smoke test.
- No live evidence in this pass proves that operators currently have one universally updated start-here surface that already reflects the post-pivot bot story.

## Canonical bot after pivot

`@open_claudebot` (`8229279102`)

Operator rule:

- this is the only canonical Telegram bot after the pivot succeeds
- this is the bot operators should message for normal smoke tests after the pivot
- this is the identity that `claudeclaw-hosted.service` should own in normal post-pivot operation

## Legacy bot after pivot

`@openclawlobbybot` (`8375038775`)

Operator rule:

- this is demoted to legacy after the pivot succeeds
- this must not remain an implied "also-canonical" production target
- this should only be used again if rollback is explicitly declared
- if rollback is declared, this bot becomes the temporary rollback production bot until the failed pivot is corrected

## Rollback posture

Rollback remains possible, but the target of rollback must be stated explicitly: restore `@openclawlobbybot` as the only Telegram production owner.

Rollback should restore all of the following together:

- bot identity: `@openclawlobbybot` (`8375038775`)
- allowed operator user: `7807161252`
- single-owner posture: only one Telegram poller should own production
- fallback posture: `openclaw-gateway.service` remains live unless a separate incident requires otherwise

Rollback should not mean "leave both runtimes alive and hope operators remember which bot is real."

Operationally, the restore source should be:

1. Preferred: a fresh pre-pivot backup of the hosted Telegram env and hosted runtime settings while they still point to `8375038775`.
2. Proven fallback: the existing rollback anchor at `/home/openclaw/migration-snapshots/20260317T102337Z-pre-claudeclaw/`, which already preserves the legacy `8375038775` token path.

## Exact stale surfaces that must be updated

These files either name `@openclawlobbybot` as the active production bot, still describe the pivot as not done, or leave rollback too generic. Once `@open_claudebot` becomes canonical, they must be updated or clearly bannered as historical.

- `HOSTED_OPERATOR_START_HERE.md`
  - Current pivot-state framing lives at lines `12-20` and current live truth at lines `24-33`.
  - After pivot success, this file must say `@open_claudebot` is canonical, `@openclawlobbybot` is legacy, and rollback restores `@openclawlobbybot`.
- `HOSTED_CLAUDECLAW_SERVICE_OWNERSHIP.md`
  - Current ownership summary is at lines `16-24`; current live bot identity is at lines `76-88`.
  - After pivot success, this file must stop treating `@openclawlobbybot` as the live hosted bot.
- `BOT_IDENTITY_TRUTH.md`
  - Current bot-identity truth is centered on `@openclawlobbybot` at lines `7-16`, `27-43`, and `59-65`.
  - After pivot success, this file must either be replaced with new truth for `@open_claudebot` or marked historical.
- `CLAUDECLAW_HOSTED_TELEGRAM_ROLLBACK_EXECUTION_SHEET.md`
  - Rollback goal and steps are at lines `12-22` and `47-105`.
  - After pivot success, this file must explicitly say rollback restores `@openclawlobbybot` as the single production owner, not just "legacy Telegram ownership."
- `CUTOVER_WINDOW_AUTHORIZED.env`
  - Lines `3-6` currently declare `openclawlobbybot` as `TARGET_PRODUCTION_BOT_*` and `open_claudebot` as `HOSTED_SMOKE_BOT_*`.
  - After pivot success, this must be inverted, superseded, or archived to avoid misleading later operators.
- `CLAUDECLAW_CANONICAL_MIGRATION.md`
  - Hosted-current note at lines `11-17` and hosted state at lines `52-58` still describe pre-pivot or legacy-owner assumptions.
  - After pivot success, those sections must be updated or clearly marked historical.
- `CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_RUNBOOK.md`
  - Lines `3-14` still classify the cutover as `NO-GO, NOT ATTEMPTED`.
  - After pivot success, this should be archived or bannered as pre-pivot history.
- `CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_READINESS_NOTE.md`
  - Lines `6-43` still present a pre-pivot readiness verdict and contain stale or conflicting bot claims.
  - After pivot success, this should be archived or bannered as pre-pivot history.
- `CUTOVER_EXECUTION_LOG.md`
  - Lines `11-14`, `56-64`, and `125-130` assert that `@openclawlobbybot` is the production bot.
  - Keep as historical evidence, but do not leave it looking like current operator truth after the new pivot.
- `POST_CUTOVER_ROLLBACK_READINESS.md`
  - Lines `13-16`, `54-89`, and `147-170` treat `@openclawlobbybot` as the active hosted production bot and rollback target.
  - Keep as historical evidence for the old state or update the header to say it is pre-`@open_claudebot` pivot material.

## Recommended operator note wording

Use this wording, or materially equivalent wording, in the main start-here surface once the pivot is approved and executed:

```md
Canonical Telegram bot after the 2026-03-17 bot-identity pivot is `@open_claudebot` (`8229279102`).
`@openclawlobbybot` (`8375038775`) is legacy/demoted and is not a normal production test target.

If rollback is declared, rollback restores `@openclawlobbybot` as the single Telegram production owner and temporarily re-promotes it for incident handling.
Do not leave both bot identities, both Telegram pollers, or both operator instructions looking active at the same time.

Normal post-pivot smoke target: `@open_claudebot`
Declared rollback smoke target: `@openclawlobbybot`
```
