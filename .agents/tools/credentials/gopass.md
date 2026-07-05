---
description: gopass encrypted secret management with AI-native wrapper
mode: subagent
tools:
  read: true
  write: false
  edit: false
  bash: true
  glob: false
  grep: false
  webfetch: false
  task: false
---

<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# gopass - Encrypted Secret Management

<!-- AI-CONTEXT-START -->

## Quick Reference

- **Backend**: gopass (GPG/age encrypted, git-versioned, team-shareable)
- **CLI**: `maestro secret <command>` or `secret-helper.sh <command>`
- **Store path**: `~/.local/share/gopass/stores/root/maestro/`
- **Fallback**: `~/.config/maestro/credentials.sh` (plaintext, chmod 600)

| Command | Purpose |
|---------|---------|
| `maestro secret set NAME` | Store secret (interactive hidden input) |
| `maestro secret list` | List names only (never values) |
| `maestro secret run CMD` | Inject all secrets, redact output |
| `maestro secret NAME -- CMD` | Inject specific secret, redact output |
| `maestro secret init` | Initialize gopass store |
| `maestro secret import-credentials` | Migrate from credentials.sh |
| `maestro secret status` | Show backend status |

**CRITICAL**: NEVER use `gopass show`, `gopass cat`, or any command that prints secret values in agent context.

<!-- AI-CONTEXT-END -->

## Installation

```bash
brew install gopass          # macOS
apt install gopass           # Debian/Ubuntu
pacman -S gopass             # Arch
maestro secret init         # Auto-installs if missing
```

**Prerequisites**: `brew install gnupg pinentry-mac` (macOS); git (already required).

## Setup

```bash
maestro secret init                 # Creates GPG key if needed
maestro secret import-credentials  # Migrate from credentials.sh
```

## Usage

### Storing Secrets

Run in your own terminal — never paste values into AI chat:

```bash
maestro secret set GITHUB_TOKEN     # Enter raw value at hidden prompt
maestro secret set OPENAI_API_KEY
```

Verify with `maestro secret list`.

### Naming with multiple accounts

When you hold credentials for multiple accounts on the same provider **at once** (personal + work GitHub, multiple OpenAI projects, several Hetzner projects, prod + staging AWS), suffix the canonical env var with a short account tag. Convention: `<PROVIDER>_<KIND>_<ACCOUNT>`, SCREAMING_SNAKE_CASE, account tag **last** so prefix-grep still groups by provider:

```bash
maestro secret set GITHUB_TOKEN_PERSONAL
maestro secret set GITHUB_TOKEN_WORK
maestro secret set OPENAI_API_KEY_PERSONAL
maestro secret set OPENAI_API_KEY_CLIENT_ACME
maestro secret set HCLOUD_TOKEN_PROJECT_A
maestro secret set HCLOUD_TOKEN_PROJECT_B
maestro secret set AWS_ACCESS_KEY_ID_PROD
maestro secret set AWS_ACCESS_KEY_ID_STAGING
```

The bare provider name (`GITHUB_TOKEN`, `OPENAI_API_KEY`) remains the default for the single-account case — only suffix when you actually need to disambiguate. If you instead need one account active **at a time** and want to switch sets between projects, use `multi-tenant.md`.

### Using Secrets in Commands

```bash
maestro secret run npx some-mcp-server          # Inject all secrets, redact output
maestro secret GITHUB_TOKEN -- gh api /user     # Inject specific secret
```

## Team Sharing

```bash
gpg --import teammate-public-key.asc
gopass recipients add teammate@example.com
gopass sync
```

## Agent Instructions

Warn user before requesting a secret:

> Never paste secret values into AI chat. Run `maestro secret set SECRET_NAME` in your terminal.

Then use: `maestro secret SECRET_NAME -- command` (output auto-redacted).

**Env var, not argument**: ALWAYS inject secrets as env vars, never command arguments — args appear in `ps`, error messages, and logs. `maestro secret NAME -- cmd` handles this automatically. See `reference/secret-handling.md` §8.3.

**Prohibited** (NEVER run in agent context):

- `gopass show` / `gopass cat` — prints secret values
- `cat ~/.config/maestro/credentials.sh` — exposes plaintext
- `echo $SECRET_NAME` / `env | grep` — leaks to agent context
- `cmd "$SECRET"` — secret as argument, visible in `ps` and error output

## Encryption Stack

gopass handles individual secrets (API keys, tokens, passwords). For other needs:

- **Config files in git**: SOPS — `tools/credentials/sops.md`
- **Directory encryption**: gocryptfs — `tools/credentials/gocryptfs.md`
- **Decision guide**: `tools/credentials/encryption-stack.md`

## Related

- `tools/credentials/encryption-stack.md` — Full encryption stack and decision tree
- `tools/credentials/sops.md` — SOPS config file encryption
- `tools/credentials/gocryptfs.md` — gocryptfs directory encryption
- `tools/credentials/api-key-setup.md` — Plaintext credential setup
- `tools/credentials/multi-tenant.md` — Multi-tenant credential storage
- `tools/credentials/psst.md` — psst alternative for solo devs (no GPG)
- `tools/credentials/list-keys.md` — List configured keys
- `.agents/scripts/secret-helper.sh` — Implementation
- `.agents/scripts/credential-helper.sh` — Multi-tenant plaintext backend
