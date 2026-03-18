# BOT IDENTITY DRIFT ROOT CAUSE

## Status Summary

The contradiction came from **phase mixing**, not from a current live mismatch.

Earlier on 2026-03-17, hosted ClaudeClaw really was running the **smoke bot** `@open_claudebot` (`8229279102`). During cutover at `2026-03-17 20:48-20:49 UTC`, the hosted source-of-truth token was changed to the **production bot** `@openclawlobbybot` (`8375038775`), the rendered runtime settings were updated from that same source, and every later hosted startup journal line re-announced `@openclawlobbybot`.

The team drifted because operator-facing artifacts kept both identities in circulation at once:

- the cutover authorization file explicitly named both a `TARGET_PRODUCTION_BOT_*` and a `HOSTED_SMOKE_BOT_*`
- historical preflight samples and backups under the canonical hosted ops path still showed `@open_claudebot`
- a stale readiness note still claimed hosted journal output said `Bot: @open_claudebot`
- newer cutover and post-cutover docs claimed victory on `@openclawlobbybot`

So the current live identity and the historical hosted smoke identity were both true at different phases, but not at the same time.

## What is PROVEN

### 1. Current live source-of-truth and rendered config agree on `@openclawlobbybot`

- Current hosted source-of-truth file is:
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
- Current rendered runtime file is:
  - `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
- Live VM readout showed:
  - `ENV_TOKEN_PREFIX=8375038775`
  - `SETTINGS_TOKEN_PREFIX=8375038775`
  - `TOKEN_PREFIX_MATCH=True`
  - both env and rendered settings allow user `7807161252`

### 2. Current hosted runtime is observing `@openclawlobbybot`, not `@open_claudebot`

- Telegram `getMe` using the current hosted runtime token returned:
  - `id=8375038775`
  - `username=openclawlobbybot`
- Hosted service journal since cutover shows only `@openclawlobbybot`:
  - `2026-03-17 20:49:17 UTC`
  - `2026-03-17 20:49:24 UTC`
  - `2026-03-17 21:29:52 UTC`
  - `2026-03-17 22:02:46 UTC`

### 3. The live service path that owns bot identity is exact and traceable

- `/home/openclaw/.config/systemd/user/claudeclaw-hosted.service`
  - `ExecStart=/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.sh`
  - `EnvironmentFile=-/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.env`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.env`
  - sets `HOSTED_TELEGRAM_ENV_FILE=/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
  - sets `HOSTED_TELEGRAM_RENDER_SCRIPT=/home/openclaw/claudeclaw/ops/claudeclaw-hosted/render-hosted-telegram-settings.sh`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.sh`
  - calls the render helper before starting ClaudeClaw
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/render-hosted-telegram-settings.sh`
  - reads `CLAUDECLAW_TELEGRAM_TOKEN` and `CLAUDECLAW_TELEGRAM_ALLOWED_USER_IDS`
  - writes them into `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`

### 4. `state.json` is not the bot identity owner

- Current state file is:
  - `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/state.json`
- It currently shows `telegram: true`, startup time, and web state.
- It does **not** contain bot username, bot ID, or token fields.

### 5. Hosted ClaudeClaw really did use `@open_claudebot` earlier in the day

- Hosted service journal contains older hosted startup lines with:
  - `2026-03-17 12:00:47 UTC   Bot: @open_claudebot`
  - `2026-03-17 12:00:52 UTC   Bot: @open_claudebot`
  - `2026-03-17 14:08:03 UTC   Bot: @open_claudebot`
  - `2026-03-17 14:25:36 UTC   Bot: @open_claudebot`
  - `2026-03-17 16:05:44 UTC   Bot: @open_claudebot`
- Historical hosted ops artifacts also preserve that identity:
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150216Z.txt`
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150343Z.txt`
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150456Z.txt`
- One sample explicitly records:
  - `telegram_bot_id=8229279102`
  - `telegram_bot_username=open_claudebot`

### 6. Historical hosted backups prove the hosted token used to be `8229279102`

- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T160544Z-telegram-isolation/settings.json`
  - token prefix `8229279102`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/settings.json`
  - token prefix `8229279102`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/claudeclaw-telegram.env`
  - historical hosted env for the same smoke phase

### 7. Cutover docs prove the hosted identity was intentionally changed later to `@openclawlobbybot`

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CUTOVER_WINDOW_AUTHORIZED.env` explicitly names:
  - `TARGET_PRODUCTION_BOT_USERNAME=openclawlobbybot`
  - `TARGET_PRODUCTION_BOT_ID=8375038775`
  - `HOSTED_SMOKE_BOT_USERNAME=open_claudebot`
  - `HOSTED_SMOKE_BOT_ID=8229279102`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CUTOVER_EXECUTION_LOG.md` says the mutation step:
  - populated `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
  - copied in the legacy production token from `/home/openclaw/cornerstone/.env`
  - rendered runtime settings
  - restarted `claudeclaw-hosted.service`
  - stopped `cornerstone-telegram.service`
- Current live file mtimes line up with that sequence:
  - `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env` at `2026-03-17 20:48:43 UTC`
  - hosted journal re-announced `Bot: @openclawlobbybot` at `2026-03-17 20:49:17 UTC`

## What is INFERRED

- The drift was caused by a **combination** of:
  - mixed bot usage across phases
  - stale docs
  - historical smoke artifacts left in canonical ops locations
- The operator claim that ClaudeClaw was “actually using `@open_claudebot`” is consistent with the earlier hosted smoke phase, but inconsistent with the current live production config after `2026-03-17 20:49 UTC`.
- Testing `@open_claudebot` after cutover would hit a historical smoke identity, not the current production identity path.
- The project lacked one clearly published operator rule saying:
  - “bot identity is owned by `claudeclaw-telegram.env`, rendered into `.claude/claudeclaw/settings.json`, and confirmed by hosted journal `Bot: @...` plus `getMe`.”

## What is NOT PROVEN

- It is **not proven** that there is a current token source mismatch.
  - Current env and rendered settings match on `8375038775`.
- It is **not proven** that there is a current rendered-settings mismatch.
  - The wrapper and render helper point to the same live files now in use.
- It is **not proven** that `state.json` ever owned identity.
  - It only proves enabled/disabled runtime state.
- It is **not proven** from this pass which exact bot the operator used for each failed manual test.
  - The task brief reports that `@openclawlobbybot` returned “Unknown” and `@open_claudebot` received messages but did not answer, but that user-action sequence is not independently reconstructable from the files inspected here.
- It is **not proven** in this pass why `@openclawlobbybot` failed to answer some probes.
  - That is a separate receive/process-path question from identity ownership.

## Root Cause Classification

**Primary root cause:** mixed bot usage across phases plus stale operator-facing evidence.

**Not the root cause:** a current live token mismatch between the hosted source-of-truth env and rendered runtime settings.

In short:

- before cutover, hosted ClaudeClaw used the smoke bot `@open_claudebot`
- during cutover, hosted source-of-truth was switched to the production bot `@openclawlobbybot`
- after cutover, some docs and samples still described the smoke bot while newer docs described the production bot
- operators therefore had two plausible bot identities in front of them

## Exact Source-of-Truth Bot Identity Path

Current live bot identity ownership path:

1. `/home/openclaw/.config/systemd/user/claudeclaw-hosted.service`
2. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-hosted.env`
3. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`
4. `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/render-hosted-telegram-settings.sh`
5. `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`
6. runtime journal `Bot: @...`
7. Telegram Bot API `getMe`

The actual identity-owning secret/config surface is:

- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`

The rendered, runtime-consumed surface is:

- `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`

The runtime-observed confirmation surfaces are:

- hosted journal lines from `claudeclaw-hosted.service`
- `getMe` for the token currently in rendered settings

## Exact Stale/Misleading Surfaces

### Stale or misleading operator-facing docs

- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CLAUDECLAW_HOSTED_TELEGRAM_CUTOVER_READINESS_NOTE.md`
  - still says hosted journal showed `Bot: @open_claudebot`
- `/Users/malik.roberts/Library/CloudStorage/OneDrive-insidemedia.net/Desktop/theclaw/CUTOVER_WINDOW_AUTHORIZED.env`
  - keeps both `TARGET_PRODUCTION_BOT_*` and `HOSTED_SMOKE_BOT_*` in the same operator artifact

### Historical hosted artifacts that are true for the old smoke phase, but misleading if treated as live truth

- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150216Z.txt`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150343Z.txt`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/hosted-telegram-preflight.sample-20260317T150456Z.txt`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T160544Z-telegram-isolation/settings.json`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/claudeclaw-telegram.env`
- `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/backups/20260317T164513Z-telegram-runtime-truth/settings.json`

These artifacts are not wrong. They are historical. They become misleading only when read as if they still describe the live production bot.

## Recommended Next Repair Step, If Any

The smallest credible fix is a **documentation repair, not a runtime change**:

1. Mark `@open_claudebot` / `8229279102` everywhere as `historical smoke bot only`.
2. Add one canonical operator sentence in the primary status doc:
   - “Live production bot identity is owned by `/home/openclaw/claudeclaw/ops/claudeclaw-hosted/claudeclaw-telegram.env`, rendered into `/home/openclaw/claudeclaw/theclaw/.claude/claudeclaw/settings.json`, and currently resolves via `getMe` to `@openclawlobbybot` (`8375038775`).”
3. Retire or banner the stale readiness note that still says `Bot: @open_claudebot`.

If only one edit is allowed, make it the stale readiness note, because it is the cleanest single-file contradiction against the live state.
