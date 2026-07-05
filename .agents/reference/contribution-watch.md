<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Contribution Watch

Monitors external issues/PRs via GitHub Notifications API. Managed repos (`pulse: true`) excluded.

**CLI**: `contribution-watch-helper.sh seed|scan|status|install|uninstall`

- `seed` — seed tracked threads from contributed repos
- `scan` — check for new activity (`--backfill` for safety-net sweeps)
- `install` / `uninstall` — manage scheduled scanner

**Security**: Deterministic metadata checks (no LLM). Comment bodies shown only in interactive sessions after `prompt-guard-helper.sh scan`.

## Related

- `reference/services.md` — Services & Integrations index
