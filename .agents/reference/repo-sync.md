<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Repo Sync

Daily `git pull --ff-only` for repos in configured parent dirs. Fast-forwards clean, default-branch checkouts only. Skips dirty trees, non-default branches, no-remote repos, worktrees.

**CLI**: `maestro repo-sync [enable|disable|status|check|dirs|config|logs]` — `check` for immediate one-shot.

**Scheduler**: macOS launchd (`~/Library/LaunchAgents/com.maestro.maestro-repo-sync.plist`); Linux cron (daily 3am).

**Disable**: `maestro repo-sync disable`, `"repo_sync": false` in settings.json, or `MAESTRO_REPO_SYNC=false`. Interval: `MAESTRO_REPO_SYNC_INTERVAL=1440` (minutes, default daily).

**Parent dirs** (`~/.config/maestro/repos.json`, default `~/Git`):

```bash
maestro repo-sync dirs list           # Show configured directories
maestro repo-sync dirs add ~/Projects # Add a parent directory
maestro repo-sync dirs remove ~/Old   # Remove a parent directory
```

**Logs**: `~/.maestro/logs/repo-sync.log` — `maestro repo-sync logs [--tail N|--follow]`. **Status**: `maestro repo-sync status`.

## Related

- `reference/services.md` — Services & Integrations index
