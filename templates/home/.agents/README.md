<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# AI Agent Working Directory

**DEPRECATED: This location is being phased out.**

The maestro framework now uses `~/.maestro/` for all working files.

## New Structure

```text
~/.maestro/
├── agents/                    # Agent files (deployed from repo)
├── .agent-workspace/          # Your working files
│   ├── work/[project]/        # Persistent project files
│   ├── tmp/session-*/         # Temporary session files
│   └── memory/                # Cross-session patterns
└── config-backups/            # Configuration backups
```

## Migration

Run `setup.sh` from the maestro repository to deploy to the new location:

```bash
cd ~/Git/maestro
./setup.sh
```

## Credential Storage

Credentials remain in `~/.config/maestro/mcp-env.sh` (600 permissions).

---
**Repository**: https://github.com/Aditya060806/Maestro
