<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# maestro Settings Reference

**File**: `~/.config/maestro/settings.json` — created by `setup.sh` or `settings-helper.sh init`
**Helper**: `~/.maestro/agents/scripts/settings-helper.sh`

**Precedence** (highest wins): env var (`MAESTRO_*`) → `settings.json` → built-in default

## Settings

### auto_update

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `auto_update.enabled` | boolean | `true` | `MAESTRO_AUTO_UPDATE` | Master switch for all auto-updates. |
| `auto_update.interval_minutes` | number | `10` | `MAESTRO_UPDATE_INTERVAL` | Minutes between update checks (1–1440). |
| `auto_update.skill_auto_update` | boolean | `true` | `MAESTRO_SKILL_AUTO_UPDATE` | Daily skill freshness checks. |
| `auto_update.skill_freshness_hours` | number | `24` | `MAESTRO_SKILL_FRESHNESS_HOURS` | Hours between skill checks. |
| `auto_update.tool_auto_update` | boolean | `true` | `MAESTRO_TOOL_AUTO_UPDATE` | Periodic tool updates (npm, brew, pip) — idle-only. |
| `auto_update.tool_freshness_hours` | number | `6` | `MAESTRO_TOOL_FRESHNESS_HOURS` | Hours between tool checks. |
| `auto_update.tool_idle_hours` | number | `6` | `MAESTRO_TOOL_IDLE_HOURS` | Required idle time before tool updates run. |
| `auto_update.openclaw_auto_update` | boolean | `true` | `MAESTRO_OPENCLAW_AUTO_UPDATE` | Daily OpenClaw update checks (if installed). |
| `auto_update.openclaw_freshness_hours` | number | `24` | `MAESTRO_OPENCLAW_FRESHNESS_HOURS` | Hours between OpenClaw checks. |
| `auto_update.upstream_watch` | boolean | `true` | `MAESTRO_UPSTREAM_WATCH` | Daily upstream repo release monitoring. |
| `auto_update.upstream_watch_hours` | number | `24` | `MAESTRO_UPSTREAM_WATCH_HOURS` | Hours between upstream checks. |

### supervisor

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `supervisor.pulse_enabled` | boolean | `true` | `MAESTRO_SUPERVISOR_PULSE` | Enable pulse scheduler — dispatches workers every `pulse_interval_seconds`. |
| `supervisor.pulse_interval_seconds` | number | `180` | -- | Seconds between pulse cycles (30–3600). Default raised from 120 in t2744 to reduce GraphQL pressure. |
| `supervisor.stale_threshold_seconds` | number | `1800` | -- | Seconds before a worker is considered stuck. |
| `supervisor.circuit_breaker_max_failures` | number | `3` | -- | Consecutive failures before dispatch pauses. |
| `supervisor.strategic_review_hours` | number | `4` | -- | Hours between opus-tier queue health reviews. |
| `supervisor.peak_hours_enabled` | boolean | `false` | `MAESTRO_PEAK_HOURS_ENABLED` | Cap workers during peak window. **Disabled by default.** |
| `supervisor.peak_hours_start` | number | `5` | `MAESTRO_PEAK_HOURS_START` | Peak window start hour (0–23, local time). Overnight: set start > end. |
| `supervisor.peak_hours_end` | number | `11` | `MAESTRO_PEAK_HOURS_END` | Peak window end hour (0–23, exclusive). |
| `supervisor.peak_hours_tz` | string | `"America/Los_Angeles"` | `MAESTRO_PEAK_HOURS_TZ` | Documentation label — pulse uses system `date +%H`. |
| `supervisor.peak_hours_worker_fraction` | number | `0.2` | `MAESTRO_PEAK_HOURS_WORKER_FRACTION` | Fraction of off-peak workers allowed during peak (min 1, rounded up). `calculate_max_workers()` applies this after the RAM-based clamp — cap can only reduce, never increase. |

### repo_sync

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `repo_sync.enabled` | boolean | `true` | `MAESTRO_REPO_SYNC` | Daily `git pull --ff-only` on clean repos. |
| `repo_sync.schedule` | string | `"daily"` | -- | Sync schedule (`daily` only). |

### quality

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `quality.shellcheck_enabled` | boolean | `true` | -- | Run ShellCheck on shell scripts. |
| `quality.sonarcloud_enabled` | boolean | `true` | -- | Run SonarCloud analysis. |
| `quality.write_time_linting` | boolean | `true` | -- | Lint after each edit, not just at commit. |

### model_routing

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `model_routing.default_tier` | string | `"sonnet"` | -- | Default tier for untagged tasks (`haiku`, `sonnet`, `opus`, `flash`, `pro`). |
| `model_routing.budget_tracking_enabled` | boolean | `true` | -- | Track per-provider API spend. |
| `model_routing.prefer_subscription` | boolean | `true` | -- | Prefer subscription over API billing when both available. |

### onboarding

Tracks onboarding state. Written by `/onboarding`, readable by scripts.

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `onboarding.completed` | boolean | `false` | -- | Whether `/onboarding` has been completed. |
| `onboarding.work_type` | string | `""` | -- | Primary work type (e.g., `"web"`, `"devops"`, `"seo"`, `"wordpress"`). |
| `onboarding.familiarity` | array | `[]` | -- | Concepts the user knows (e.g., `["git", "terminal", "api_keys"]`). |

### ui

| Key | Type | Default | Env Var | Description |
|-----|------|---------|---------|-------------|
| `ui.color_output` | boolean | `true` | -- | Colored terminal output. |
| `ui.verbose` | boolean | `false` | -- | Verbose/debug output in scripts. |

## Usage

```bash
settings-helper.sh init                          # create with defaults
settings-helper.sh get auto_update.enabled       # read a value
settings-helper.sh set auto_update.enabled false # write a value
settings-helper.sh list                          # all settings
settings-helper.sh validate                      # check file
eval "$(settings-helper.sh export-env)"          # export as env vars
```

From scripts — use the helper (respects env > file > default precedence):

```bash
value=$(~/.maestro/agents/scripts/settings-helper.sh get auto_update.enabled)
# or direct jq (file only, no env precedence):
value=$(jq -r '.auto_update.enabled' ~/.config/maestro/settings.json)
```

Edit directly: `${EDITOR:-vi} ~/.config/maestro/settings.json`

## Migration from Environment Variables

Env vars continue to work as overrides — no migration required. To consolidate, remove `MAESTRO_*` exports from your shell config and set values in `settings.json` instead. The `Env Var` column in each table above shows the mapping.

## Peak Hours Configuration

Enable to cap workers during Anthropic's session-limit window (weekday 5–11 AM PT):

```bash
settings-helper.sh set supervisor.peak_hours_enabled true
settings-helper.sh set supervisor.peak_hours_start 5
settings-helper.sh set supervisor.peak_hours_end 11
settings-helper.sh set supervisor.peak_hours_worker_fraction 0.2
```
