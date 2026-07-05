<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Configuration Reference

maestro uses two complementary configuration files.

## Configuration Files

| File | Format | Purpose | Managed by |
|------|--------|---------|------------|
| `~/.config/maestro/config.jsonc` | JSONC | Framework behaviour: updates, models, safety, quality, orchestration, paths | `config-helper.sh` / `maestro config` |
| `~/.config/maestro/settings.json` | JSON | User preferences: onboarding state, UI, model routing defaults | `settings-helper.sh` |

Both created automatically on first run. Neither required — sensible defaults apply when absent.

`settings.json` was introduced first (t1379) as a lightweight key-value store. `config.jsonc` was added later (t2730) as a namespaced, schema-validated system. `config.jsonc` is the primary configuration surface going forward.

## Precedence (highest wins)

1. **Environment variable** (`MAESTRO_*`) — always wins
2. **User config file** — persistent overrides
3. **Built-in defaults** — hardcoded in the helper or defaults file

Defaults file (overwritten on `maestro update` — do not edit):

```text
~/.maestro/agents/configs/maestro.defaults.jsonc
```

## Quick Start

**config.jsonc** (`maestro config`):

```bash
maestro config list                          # View all with current values
maestro config get updates.auto_update       # Get a value
maestro config set updates.auto_update false # Set a value
maestro config reset updates.auto_update     # Reset to default
maestro config reset                         # Reset all to defaults
maestro config validate                      # Validate against schema
maestro config path                          # Show file paths
maestro config migrate                       # Migrate from legacy feature-toggles.conf
```

**settings.json** (`settings-helper.sh`):

```bash
settings-helper.sh init                          # Create with defaults
settings-helper.sh get auto_update.enabled       # Get a value
settings-helper.sh set auto_update.enabled false # Set a value
settings-helper.sh list                          # List all
eval "$(settings-helper.sh export-env)"          # Export as shell env vars
```

**Schema validation** — add `"$schema"` to your config for editor autocomplete:

```jsonc
{
  "$schema": "~/.maestro/agents/configs/maestro-config.schema.json"
}
```

Schema file: `~/.maestro/agents/configs/maestro-config.schema.json`. Programmatic access:

```bash
source ~/.maestro/agents/scripts/config-helper.sh
value=$(_jsonc_get "updates.auto_update")
```

---

## config.jsonc — Full Reference

Supports `//` line comments, `/* block comments */`, and trailing commas.

### updates

Auto-update behaviour for maestro, skills, tools, and OpenClaw.

| Key | Type | Default | Env Override | Description |
|-----|------|---------|-------------|-------------|
| `updates.auto_update` | boolean | `true` | `MAESTRO_AUTO_UPDATE` | Master switch. `false` disables all automatic updates. Manual: `maestro update`. |
| `updates.update_interval_minutes` | integer | `10` | `MAESTRO_UPDATE_INTERVAL` | Minutes between update checks. Min: 1. |
| `updates.skill_auto_update` | boolean | `true` | `MAESTRO_SKILL_AUTO_UPDATE` | Check imported skills for upstream changes. |
| `updates.skill_freshness_hours` | integer | `24` | `MAESTRO_SKILL_FRESHNESS_HOURS` | Hours between skill freshness checks. Min: 1. |
| `updates.tool_auto_update` | boolean | `true` | `MAESTRO_TOOL_AUTO_UPDATE` | Update installed tools (npm, brew, pip) when idle. |
| `updates.tool_freshness_hours` | integer | `6` | `MAESTRO_TOOL_FRESHNESS_HOURS` | Hours between tool freshness checks. Min: 1. |
| `updates.tool_idle_hours` | integer | `6` | `MAESTRO_TOOL_IDLE_HOURS` | Required idle hours before tool updates run. Min: 1. |
| `updates.openclaw_auto_update` | boolean | `true` | `MAESTRO_OPENCLAW_AUTO_UPDATE` | Check for OpenClaw updates (only if `openclaw` CLI installed). |
| `updates.openclaw_freshness_hours` | integer | `24` | `MAESTRO_OPENCLAW_FRESHNESS_HOURS` | Hours between OpenClaw update checks. Min: 1. |

### integrations

Controls whether `setup.sh` manages external AI assistant configurations.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `integrations.manage_opencode_config` | boolean | `true` | Allow `setup.sh` to modify OpenCode config. `false` if you manage `opencode.json` manually. |
| `integrations.manage_claude_config` | boolean | `true` | Allow `setup.sh` to modify Claude Code config. `false` if you manage it manually. |

### orchestration

Supervisor, dispatch, and autonomous operation settings.

| Key | Type | Default | Env Override | Description |
|-----|------|---------|-------------|-------------|
| `orchestration.supervisor_pulse` | boolean | `true` | `MAESTRO_SUPERVISOR_PULSE` | Enable the autonomous supervisor pulse. Dispatches workers, merges PRs, evaluates results every 3 minutes (configurable via `supervisor.pulse_interval_seconds`). |
| `orchestration.repo_sync` | boolean | `true` | `MAESTRO_REPO_SYNC` | Daily `git pull --ff-only` on clean repos in `repos.json`. |
| `orchestration.max_workers_cap` | integer | RAM-derived, capped at `64` | `MAESTRO_MAX_WORKERS_CAP` | Hard ceiling for pulse worker pool size after RAM-based calculation. |
| `orchestration.min_worker_concurrency` | integer | `6` | `MAESTRO_MIN_WORKER_CONCURRENCY` | Minimum active implementation-worker floor while provider/account health and host load permit. Set to `0` to disable. |
| `orchestration.provider_account_slot_multiplier` | integer | `24` | `PULSE_PROVIDER_ACCOUNT_SLOT_MULTIPLIER` | Worker slots allowed per available provider OAuth account. One healthy OpenAI/Anthropic account can use the configured max worker cap by default; lower this if the provider plan/account cannot sustain that concurrency. RAM, load, recent failures/rate limits/service interruptions/provider 5xx, auth errors, and explicit overrides still reduce capacity. |

### safety

Security hooks, verification, and protective measures.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `safety.hooks_enabled` | boolean | `true` | Install git pre-commit/pre-push safety hooks. `false` if hooks conflict with your workflow. |
| `safety.verification_enabled` | boolean | `true` | Parallel model verification for high-stakes operations. |
| `safety.verification_tier` | string | `"haiku"` | Model tier for verification. Options: `haiku`, `flash`, `sonnet`, `pro`, `opus`. |

### ui

User interface and session experience settings.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `ui.session_greeting` | boolean | `true` | Show version check and update prompt on session start. |
| `ui.shell_aliases` | boolean | `true` | Add maestro shell aliases to `.zshrc`/`.bashrc` during setup. |
| `ui.onboarding_prompt` | boolean | `true` | Offer to launch `/onboarding` after `setup.sh` completes. |

### models

Model routing, tiers, provider configuration, rate limits, fallback chains, and gateways.

#### models.tiers

Each tier maps to an ordered list of models. First available model is used; optional `fallback` tier is tried if all are unavailable.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `models.tiers.<name>.models` | string[] | (see defaults) | Ordered list of model identifiers. |
| `models.tiers.<name>.fallback` | string | (none) | Tier to fall back to if all models unavailable. |

**Default tiers:**

| Tier | Models | Fallback | Purpose |
|------|--------|----------|---------|
| `local` | `local/llama.cpp` | `haiku` | Offline / privacy-first tasks |
| `haiku` | `anthropic/claude-haiku-4-5` | -- | Fast, low-cost (primary name) |
| `flash` | `anthropic/claude-haiku-4-5` | -- | Alias for `haiku` |
| `sonnet` | `anthropic/claude-sonnet-4-6` | -- | Balanced capability/cost (primary name) |
| `pro` | `anthropic/claude-sonnet-4-6` | -- | Alias for `sonnet` |
| `opus` | `anthropic/claude-opus-4-6` | -- | Highest capability, highest cost |
| `coding` | `anthropic/claude-opus-4-6`, `anthropic/claude-sonnet-4-6` | -- | Code tasks: opus first, sonnet fallback |
| `eval` | `anthropic/claude-sonnet-4-6` | -- | Evaluation and grading |
| `health` | `anthropic/claude-sonnet-4-6` | -- | Health/wellness domain |

> `haiku`/`flash` and `sonnet`/`pro` are aliases — they resolve to the same model. Changing one automatically applies to the other.

**Example — add a custom tier:**

```jsonc
{
  "models": {
    "tiers": {
      "fast": {
        "models": ["openai/gpt-4o-mini", "anthropic/claude-haiku-4-5"],
        "fallback": "haiku"
      }
    }
  }
}
```

#### models.providers

Provider endpoint and authentication configuration.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `models.providers.<name>.endpoint` | string (URI) | (see defaults) | API endpoint URL. |
| `models.providers.<name>.key_env` | string or null | (see defaults) | Env var containing the API key. `null` for keyless providers. |
| `models.providers.<name>.probe_timeout_seconds` | integer | `10` | Timeout for availability probes. Min: 1. |

**Default providers:**

| Provider | Endpoint | Key Env |
|----------|----------|---------|
| `local` | `http://localhost:8080/v1/chat/completions` | `null` |
| `anthropic` | `https://api.anthropic.com/v1/messages` | `ANTHROPIC_API_KEY` |

**Example — add OpenAI:**

```jsonc
{
  "models": {
    "providers": {
      "openai": {
        "endpoint": "https://api.openai.com/v1/chat/completions",
        "key_env": "OPENAI_API_KEY",
        "probe_timeout_seconds": 10
      }
    }
  }
}
```

#### models.fallback_chains

Per-tier fallback chains for model-level failover. Each key is a tier name; value is an ordered list of model identifiers. By default, each tier's chain matches its `models.tiers` model list (e.g., `coding` chain = `[claude-opus-4-6, claude-sonnet-4-6]`). The `default` chain resolves to `anthropic/claude-sonnet-4-6`.

#### models.fallback_triggers

Error conditions that trigger fallback to the next model in the chain.

| Trigger | Enabled | Cooldown (s) | Description |
|---------|---------|--------------|-------------|
| `api_error` | `true` | `300` | General API errors (5xx, network failures). |
| `timeout` | `true` | `180` | Request timeout exceeded. |
| `rate_limit` | `true` | `60` | Provider rate limit hit (429). |
| `auth_error` | `true` | `3600` | Authentication failure (401/403). Long cooldown — likely needs manual fix. |
| `overloaded` | `true` | `120` | Provider overloaded (503). |

**Example — disable fallback on rate limits:**

```jsonc
{
  "models": {
    "fallback_triggers": {
      "rate_limit": { "enabled": false }
    }
  }
}
```

#### models.settings

General model routing settings.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `models.settings.probe_timeout_seconds` | integer | `10` | Global default timeout for provider availability probes. |
| `models.settings.cache_ttl_seconds` | integer | `300` | Cache duration for provider availability results. |
| `models.settings.max_chain_depth` | integer | `5` | Maximum fallback hops before giving up. |
| `models.settings.default_cooldown_seconds` | integer | `300` | Default cooldown after a fallback trigger fires. |
| `models.settings.log_retention_days` | integer | `30` | Days to retain model routing logs. |

#### models.rate_limits

Rate limits per provider. Adjust to match your API plan tier.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `models.rate_limits.warn_pct` | integer | `80` | Percentage of rate limit at which to warn. Range: 0-100. |
| `models.rate_limits.window_minutes` | integer | `1` | Rate limit window size. Min: 1. |
| `models.rate_limits.providers.<name>.requests_per_min` | integer | (varies) | Max requests per minute. |
| `models.rate_limits.providers.<name>.tokens_per_min` | integer | (varies) | Max tokens per minute. |

**Default rate limits:**

| Provider | Requests/min | Tokens/min |
|----------|-------------|------------|
| `anthropic` | 50 | 40,000 |
| `openai` | 500 | 200,000 |
| `google` | 60 | 1,000,000 |
| `deepseek` | 60 | 100,000 |
| `openrouter` | 200 | 500,000 |
| `groq` | 30 | 6,000 |
| `xai` | 60 | 100,000 |

**Example — increase Anthropic limits:**

```jsonc
{
  "models": {
    "rate_limits": {
      "providers": {
        "anthropic": { "requests_per_min": 200, "tokens_per_min": 200000 }
      }
    }
  }
}
```

#### models.gateways

Gateway provider configuration for provider-level fallback routing (e.g., OpenRouter, Cloudflare AI Gateway).

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `models.gateways.<name>.enabled` | boolean | `false` | Enable this gateway. |
| `models.gateways.<name>.endpoint` | string | (varies) | Gateway API endpoint. |
| `models.gateways.<name>.key_env_var` | string | (varies) | Env var for the gateway API key. |
| `models.gateways.<name>.account_id` | string | `""` | Account ID (Cloudflare). |
| `models.gateways.<name>.gateway_id` | string | `""` | Gateway ID (Cloudflare). |

**Default gateways (both disabled):**

| Gateway | Endpoint | Key Env |
|---------|----------|---------|
| `openrouter` | `https://openrouter.ai/api/v1` | `OPENROUTER_API_KEY` |
| `cloudflare` | (constructed from account/gateway IDs) | `CF_AIG_TOKEN` |

### quality

Code quality, linting, and CI/CD timing configuration.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `quality.sonarcloud_grade` | string | `"A"` | Target SonarCloud grade. Options: `A`–`E`. |
| `quality.shellcheck_max_violations` | integer | `0` | ShellCheck violation tolerance. `0` = zero tolerance. |

#### quality.ci_timing

CI/CD service timing constants (seconds). Based on observed completion times. Used by scripts that poll CI status.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `quality.ci_timing.fast_wait` | integer | `10` | Initial wait before first poll (fast services). |
| `quality.ci_timing.fast_poll` | integer | `5` | Poll interval for fast services. |
| `quality.ci_timing.medium_wait` | integer | `60` | Initial wait for medium services. |
| `quality.ci_timing.medium_poll` | integer | `15` | Poll interval for medium services. |
| `quality.ci_timing.slow_wait` | integer | `120` | Initial wait for slow services. |
| `quality.ci_timing.slow_poll` | integer | `30` | Poll interval for slow services. |
| `quality.ci_timing.fast_timeout` | integer | `60` | Timeout for fast services. |
| `quality.ci_timing.medium_timeout` | integer | `180` | Timeout for medium services. |
| `quality.ci_timing.slow_timeout` | integer | `600` | Timeout for slow services. |
| `quality.ci_timing.backoff_base` | integer | `15` | Base interval for exponential backoff. |
| `quality.ci_timing.backoff_max` | integer | `120` | Maximum backoff interval. |
| `quality.ci_timing.backoff_multiplier` | integer | `2` | Backoff multiplier per retry. |

### verification

High-stakes operation verification policy. Complements `safety.verification_enabled`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `verification.enabled` | boolean | `true` | Global verification switch. |
| `verification.default_gate` | string | `"warn"` | Default gate for uncategorised operations. Options: `block`, `warn`, `allow`. |
| `verification.cross_provider` | boolean | `true` | Use a different AI provider for verification (reduces correlated hallucinations). |
| `verification.verifier_tier` | string | `"sonnet"` | Model tier for the verifier. |
| `verification.escalation_tier` | string | `"opus"` | Model tier for escalation when verifier is uncertain. |

#### verification.categories

Per-category risk levels and gates.

| Category | Risk Level | Gate | Description |
|----------|-----------|------|-------------|
| `git_destructive` | `critical` | `block` | `git push --force`, `git reset --hard`, branch deletion on main. |
| `production_deploy` | `critical` | `block` | Deploying to production environments. |
| `data_migration` | `high` | `warn` | Database migrations, bulk data changes. |
| `security_sensitive` | `high` | `warn` | Credential changes, permission modifications. |
| `financial` | `high` | `warn` | Payment processing, invoice generation. |
| `infrastructure_destruction` | `critical` | `block` | `DROP DATABASE`, server deletion, DNS zone removal. |

Gate actions: **`block`** — prevented unless second model agrees safe. **`warn`** — proceeds with logged warning. **`allow`** — no verification.

**Example — downgrade data migration to allow:**

```jsonc
{
  "verification": {
    "categories": {
      "data_migration": { "risk_level": "medium", "gate": "allow" }
    }
  }
}
```

### paths

Directory and file path configuration. Supports `~` for home directory.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `paths.agents_dir` | string | `~/.maestro/agents` | Base installation directory for maestro agents. |
| `paths.config_dir` | string | `~/.config/maestro` | User configuration directory. |
| `paths.workspace_dir` | string | `~/.maestro/.agent-workspace` | Workspace for agent operations (work files, temp, mail, memory). |
| `paths.log_dir` | string | `~/.maestro/logs` | Log directory. |
| `paths.memory_db` | string | `~/.maestro/.agent-workspace/memory/memory.db` | SQLite memory database (cross-session memory). |
| `paths.worktree_registry_db` | string | `~/.maestro/.agent-workspace/worktree-registry.db` | Worktree registry database. |

---

## settings.json — Reference

Standard JSON (no comments). Location: `~/.config/maestro/settings.json`. Helper: `settings-helper.sh`.

Many `settings.json` keys mirror `config.jsonc` namespaces. When both are set, `config.jsonc` takes precedence for framework scripts; `settings.json` is used by `settings-helper.sh` consumers.

### Mirrored keys (config.jsonc takes precedence)

| settings.json key | Mirrors config.jsonc | Env Override |
|-------------------|---------------------|-------------|
| `auto_update.enabled` | `updates.auto_update` | `MAESTRO_AUTO_UPDATE` |
| `auto_update.interval_minutes` | `updates.update_interval_minutes` | `MAESTRO_UPDATE_INTERVAL` |
| `auto_update.skill_auto_update` | `updates.skill_auto_update` | `MAESTRO_SKILL_AUTO_UPDATE` |
| `auto_update.skill_freshness_hours` | `updates.skill_freshness_hours` | `MAESTRO_SKILL_FRESHNESS_HOURS` |
| `auto_update.tool_auto_update` | `updates.tool_auto_update` | `MAESTRO_TOOL_AUTO_UPDATE` |
| `auto_update.tool_freshness_hours` | `updates.tool_freshness_hours` | `MAESTRO_TOOL_FRESHNESS_HOURS` |
| `auto_update.tool_idle_hours` | `updates.tool_idle_hours` | `MAESTRO_TOOL_IDLE_HOURS` |
| `auto_update.openclaw_auto_update` | `updates.openclaw_auto_update` | `MAESTRO_OPENCLAW_AUTO_UPDATE` |
| `auto_update.openclaw_freshness_hours` | `updates.openclaw_freshness_hours` | `MAESTRO_OPENCLAW_FRESHNESS_HOURS` |
| `supervisor.pulse_enabled` | `orchestration.supervisor_pulse` | `MAESTRO_SUPERVISOR_PULSE` |
| `repo_sync.enabled` | `orchestration.repo_sync` | `MAESTRO_REPO_SYNC` |
| `quality.shellcheck_enabled` | `quality` namespace | -- |
| `quality.sonarcloud_enabled` | `quality` namespace | -- |
| `quality.write_time_linting` | `quality` namespace | -- |

### settings.json-only keys

These keys exist only in `settings.json` (no `config.jsonc` equivalent):

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `supervisor.pulse_interval_seconds` | number | `180` | Seconds between pulse cycles. Range: 30-3600. Default raised from 120 in t2744 to reduce GraphQL pressure. |
| `supervisor.stale_threshold_seconds` | number | `1800` | Seconds before a worker is considered stale/stuck. |
| `supervisor.circuit_breaker_max_failures` | number | `3` | Consecutive failures before circuit breaker pauses dispatch. |
| `supervisor.strategic_review_hours` | number | `4` | Hours between opus-tier strategic reviews of queue health. |
| `repo_sync.schedule` | string | `"daily"` | Sync schedule. Only `daily` supported. |
| `model_routing.default_tier` | string | `"sonnet"` | Default tier for tasks without explicit tier. Options: `haiku`, `sonnet`, `opus`, `flash`, `pro`. |
| `model_routing.budget_tracking_enabled` | boolean | `true` | Track per-provider API spend. |
| `model_routing.prefer_subscription` | boolean | `true` | Prefer subscription plans over API billing when both available. |
| `onboarding.completed` | boolean | `false` | Whether the user has completed `/onboarding`. |
| `onboarding.work_type` | string | `""` | User's primary work type (e.g., `"web"`, `"devops"`, `"seo"`, `"WordPress"`). |
| `onboarding.familiarity` | array | `[]` | Concepts the user is familiar with (e.g., `["git", "terminal", "api_keys"]`). |
| `ui.color_output` | boolean | `true` | Enable coloured terminal output. |
| `ui.verbose` | boolean | `false` | Enable verbose/debug output in scripts. |

---

## Migration

### From environment variables

Env vars continue to work as the highest-priority override. To migrate to config files, remove `MAESTRO_*` exports from your shell config and set the equivalent values via `maestro config set`.

### From feature-toggles.conf

The legacy `~/.config/maestro/feature-toggles.conf` is automatically migrated to `config.jsonc` on first use. The old file is preserved but no longer read. Manual trigger:

```bash
maestro config migrate
```

---

## Service Configuration Templates

Service credentials (Hostinger, Hetzner, GitHub, etc.) use a separate template system — **not** part of the JSONC config:

1. **Templates** (`configs/[service]-config.json.txt`) — safe to commit, contain placeholders
2. **Working files** (`configs/[service]-config.json`) — gitignored, contain actual credentials

```bash
cp ~/Git/maestro/configs/hostinger-config.json.txt ~/Git/maestro/configs/hostinger-config.json
${EDITOR:-vi} ~/Git/maestro/configs/hostinger-config.json
chmod 600 ~/Git/maestro/configs/*-config.json
```

See [the full service configuration reference](../.agents/maestro/configs.md).

---

## Complete Example

A fully customised `~/.config/maestro/config.jsonc`:

```jsonc
{
  "$schema": "~/.maestro/agents/configs/maestro-config.schema.json",

  // Check for updates hourly instead of every 10 minutes
  "updates": {
    "update_interval_minutes": 60,
    "tool_auto_update": false  // I manage tool updates manually
  },

  // Disable supervisor -- I dispatch workers manually
  "orchestration": {
    "supervisor_pulse": false
  },

  // Use opus for verification (I want the strongest reasoning)
  "safety": {
    "verification_tier": "opus"
  },

  // Quiet startup
  "ui": {
    "session_greeting": false
  },

  // Add OpenRouter as a gateway for model diversity
  "models": {
    "gateways": {
      "openrouter": {
        "enabled": true
      }
    },
    "rate_limits": {
      "providers": {
        "anthropic": {
          "requests_per_min": 200,
          "tokens_per_min": 200000
        }
      }
    }
  }
}
```
