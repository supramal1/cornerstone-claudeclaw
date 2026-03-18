# OPEN_CLAUDEBOT_CONVERGENCE_VERDICT

Last reviewed: 2026-03-17 23:19 UTC

## Final classification

`CANONICAL HOSTED IDENTITY CONVERGED; SINGLE-OWNER SMOKE NOT PROVEN`

`@open_claudebot` (`8229279102`) is now the canonical hosted bot identity for ClaudeClaw.
`@openclawlobbybot` (`8375038775`) remains the legacy bot path.

This pass proves identity convergence at the hosted config/runtime/API level.
This pass does not prove a fresh end-to-end smoke for the canonical bot.

## Exactly what changed in this pass

1. Scanned the expected sprint artifacts in the repo.
2. Confirmed `BOT_PIVOT_ROLLBACK_AND_LEGACY.md` is present.
3. Confirmed `SINGLE_OWNER_OPEN_CLAUDEBOT.md` and `OPEN_CLAUDEBOT_SINGLE_OWNER_SMOKE.md` were absent at scan time.
4. Re-proved live hosted unit state, hosted bot identity, legacy unit state, and dashboard health directly on `openclaw-vm`.
5. Re-proved what rollback means after the hosted identity convergence.
6. Refreshed the branch-level verdict surfaces to match the live post-convergence state.

## What is PROVEN

1. `claudeclaw-hosted.service` is `active/running` with:
   - `MainPID=79360`
   - `ExecMainStartTimestamp=Tue 2026-03-17 23:05:09 UTC`
2. `cornerstone-telegram.service` is `active/running` with:
   - `MainPID=812`
   - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
3. `openclaw-gateway.service` is `active/running` with:
   - `MainPID=807`
   - `ExecMainStartTimestamp=Tue 2026-03-17 22:51:01 UTC`
4. The hosted Telegram env `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env` resolves to bot ID `8229279102`.
5. The hosted runtime settings `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json` resolve to bot ID `8229279102` and `allowedUserIds=[7807161252]`.
6. Telegram Bot API `getMe` using the live hosted token returned:
   - `id=8229279102`
   - `username=open_claudebot`
   - `first_name=openclaude`
7. Hosted journal since `2026-03-17 23:05:09 UTC` contains:
   - `Telegram: enabled`
   - `Bot: @open_claudebot`
   - `Telegram bot started (long polling)`
   - `Allowed users: 7807161252`
8. No hosted `409 Conflict` or poll-error line was found in the hosted journal since `2026-03-17 23:05:09 UTC`.
9. The dashboard returned `HTTP/1.1 200 OK` at `Tue, 17 Mar 2026 23:18:58 GMT`.
10. The legacy unit token source `/home/openclaw/cornerstone/.env` resolves to bot ID `8375038775`.
11. The legacy unit therefore still points to `@openclawlobbybot`.
12. The fresh hosted rollback backup `/home/openclaw/claudeclaw-backups/20260317T230509Z-bot-identity-pivot-attempt2/` exists, and its backed-up hosted env/settings both resolve to `8375038775`.
13. `BOT_IDENTITY_PIVOT_EXECUTION.md` exists and records the successful hosted pivot to `@open_claudebot`.
14. `BOT_PIVOT_ROLLBACK_AND_LEGACY.md` exists and correctly captures the rollback split between hosted revert and legacy path.

## What is INFERRED

1. `@open_claudebot` is now the single canonical hosted bot at the inspected service/config/API surfaces, because the hosted and legacy token sources resolve to different bots.
2. `@openclawlobbybot` is now legacy/parked in operator meaning, even though its legacy service path is still active.
3. The branch is no longer blocked on identity convergence; it is blocked on smoke proof.

## What is NOT PROVEN

1. No fresh manual smoke artifact proves end-to-end receive/reply behavior for `@open_claudebot`.
2. No artifact at scan time proves a successful single-owner smoke:
   - `SINGLE_OWNER_OPEN_CLAUDEBOT.md` was absent
   - `OPEN_CLAUDEBOT_SINGLE_OWNER_SMOKE.md` was absent
3. This pass did not prove long-term soak stability after the `23:05 UTC` hosted pivot.
4. This pass did not prove whether the legacy Telegram unit should now be stopped, disabled, or retired.

## Which expected artifacts were missing at scan time

- `SINGLE_OWNER_OPEN_CLAUDEBOT.md`
- `OPEN_CLAUDEBOT_SINGLE_OWNER_SMOKE.md`

## Recommended next step

Run one fresh manual smoke against `@open_claudebot` and write the result into the missing single-owner smoke artifact.

## Exact reason for that recommendation

The canonical bot identity itself is already proven from four independent surfaces:

- hosted env
- hosted runtime settings
- hosted journal
- Telegram Bot API `getMe`

The narrow remaining risk is operational message-path proof.
Until a fresh smoke is captured, the operator can say the canonical bot identity converged, but cannot honestly say smoke is proven.
