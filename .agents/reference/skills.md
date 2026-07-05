<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Skills & Cross-Tool

Import: `maestro skill add <source>` (→ `*-skill.md` suffix)

**Discover**: `maestro skills` or `/skills`. Subcommands: `search`, `browse`, `describe`, `categories`, `recommend`, `list [--imported]`

**Online registry** ([skills.sh](https://skills.sh/)):

```bash
maestro skills search --registry "browser automation"
maestro skills install vercel-labs/agent-browser@agent-browser
```

Local search with no results → `/skills` suggests the public registry automatically.

**Persistence**: `~/.maestro/agents/`, tracked in `configs/skill-sources.json`. Daily auto-update. Only `custom/` and `draft/` survive `maestro update`.

## Related

- `scripts/commands/add-skill.md` — Add a new skill
- `scripts/commands/skills.md` — Skills management
- `reference/services.md` — Services & Integrations index
