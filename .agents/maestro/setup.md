---
description: AI assistant guide for setup.sh script
mode: subagent
tools:
  read: true
  write: true
  edit: true
  bash: true
  glob: true
  grep: true
  webfetch: false
---

<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Setup Guide - AI Assistant for setup.sh

## Quick Reference

- **Script**: `~/Git/maestro/setup.sh`
- **Run**: `cd ~/Git/maestro && ./setup.sh`
- **Update**: `git pull && ./setup.sh` (backs up existing configs automatically)
- **Scoped deploy**: `./setup.sh --stage agents` or `maestro setup --scope agents`
- **Agents**: `~/.maestro/agents/` | **Backups**: `~/.maestro/config-backups/` | **Credentials**: `~/.config/maestro/credentials.sh`

**What setup.sh does**: checks required deps (`jq`, `curl`, `ssh`, `sqlite3`) and optional deps (`sshpass`, `gh`, `glab`, `tea`); copies `.agents/` → `~/.maestro/agents/` with timestamped config backups; injects AGENTS.md pointer into `~/.opencode/AGENTS.md`, `~/.cursor/AGENTS.md`, `~/.claude/AGENTS.md`, `~/.config/cursor/AGENTS.md`; updates OpenCode agent paths in `~/.config/opencode/opencode.json`.

**Deployed structure**: `~/.maestro/agents/` (AGENTS.md, maestro/, tools/, services/, workflows/, scripts/) + `~/.maestro/config-backups/[YYYYMMDD_HHMMSS]/`

## Scoped Setup / Deploy

Use full setup for first installs, migrations, config schema changes, or broad release validation:

```bash
./setup.sh --non-interactive
maestro setup --scope full
```

Use scoped setup when the change is isolated and a full deploy would add avoidable time or lock-wait surface:

| Change type | Minimal command |
|---|---|
| Agent/script-only change | `./setup.sh --stage agents` or `maestro setup --scope agents` |
| OpenCode CLI/shim/setup logic | `./setup.sh --stage opencode` or `maestro setup --scope opencode` |
| Hook change | `./setup.sh --stage hooks` or `maestro setup --scope hooks` |
| Tabby profile change | `./setup.sh --stage tabby` or `maestro setup --scope tabby` |
| launchd/routine/pulse plist change | `./setup.sh --stage pulse` or `maestro setup --scope pulse` |

`./setup.sh --stage` also accepts the canonical stage names: `setup_opencode_cli`,
`deploy_maestro_agents`, `setup_safety_hooks`, `setup_tabby`, and
`setup_supervisor_pulse`. Unknown stages fail non-zero and print the valid list.

## Manual Configuration

If setup.sh doesn't support your AI assistant, add to its AGENTS.md or config:

```text
Add ~/.maestro/agents/AGENTS.md to context for Maestro capabilities.
```

Then point agent configurations to `~/.maestro/agents/[agent].md`.

## Troubleshooting

**Missing deps:**

```bash
brew install jq curl sqlite3    # macOS
apt-get install jq curl sqlite3 # Ubuntu/Debian
```

**OpenCode not finding agents:** Check `~/.config/opencode/opencode.json` paths; verify `~/.maestro/agents/` exists. See `tools/opencode/opencode.md`.

**Permissions:**

```bash
chmod 600 ~/.config/maestro/credentials.sh
chmod 755 ~/.maestro/agents/scripts/*.sh
```
