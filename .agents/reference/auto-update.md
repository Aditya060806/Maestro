<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Auto-Update

Polls GitHub every 10 min; runs `maestro update` on new version. Safe during active sessions.

**CLI**: `maestro auto-update [enable|disable|status|check|logs]`

**Scheduler**: Three backends depending on platform:
- **macOS**: launchd LaunchAgent (`~/Library/LaunchAgents/com.maestro.maestro-auto-update.plist`). Auto-migrates existing cron entries on first `enable`.
- **Linux (preferred)**: systemd user timer (`~/.config/systemd/user/maestro-auto-update.timer` + `.service`). Selected by `_detect_linux_scheduler` when `systemctl --user` is available — this is the default on most modern Linux desktops and servers.
- **Linux (fallback)**: cron (crontab entry with `# maestro-auto-update` marker). Used when `systemctl --user` is unavailable (e.g., containers without systemd).

## Linux systemd: logout persistence (linger)

On Linux hosts using the systemd backend, the auto-update timer runs inside the **user** systemd manager. By default, the user manager stops when your last session ends — taking the timer with it.

**When you need linger**: always on servers and headless hosts where you SSH in, run `maestro auto-update enable`, then log out. Without linger, the timer fires only while you're logged in.

**When you don't need it**: laptops or desktops where a graphical session is always running.

**Enable once** (requires sudo):

```bash
sudo loginctl enable-linger $USER
```

Check current state: `maestro auto-update status` shows a `Linger: yes|no` row on systemd hosts.

**Disable**: `maestro auto-update disable`, `"auto_update": false` in settings.json, or `MAESTRO_AUTO_UPDATE=false`. Priority: env > settings.json > default (`true`). **Logs**: `~/.maestro/logs/auto-update.log`

**Skill refresh**: 24h-gated via `skill-update-helper.sh --auto-update --quiet`. Disable: `MAESTRO_SKILL_AUTO_UPDATE=false`. Frequency: `MAESTRO_SKILL_FRESHNESS_HOURS=<hours>` (default: 24).

**Upstream watch**: `upstream-watch-helper.sh check` — monitors external repos for new releases. Config: `.agents/configs/upstream-watch.json`. State: `~/.maestro/cache/upstream-watch-state.json`. Commands: `status`, `check`, `ack <slug>`.

**Update behavior**: Shared agents overwritten on update. Only `custom/` and `draft/` preserved.

## Related

- `reference/services.md` — Services & Integrations index
