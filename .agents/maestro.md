---
name: maestro
description: Framework operations subagent - use @maestro for setup, configuration, troubleshooting (Build+ is the primary agent)
mode: subagent
subagents:
  # Framework internals
  - setup
  - troubleshooting
  - architecture
  - add-new-mcp-to-maestro
  - mcp-integrations
  - mcp-troubleshooting
  - configs
  - providers
  # Agent development
  - build-agent
  - agent-review
  - build-mcp
  - server-patterns
  - api-wrapper
  - transports
  - deployment
  # Workflows
  - git-workflow
  - release
  - version-bump
  - preflight
  - postflight
  # Code quality
  - code-standards
  - linters-local
  - secretlint
  # Credentials
  - api-key-setup
  - api-key-management
  - vaultwarden
  - list-keys
  # Built-in
  - general
  - explore
---

<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Maestro - Framework Operations Subagent

## Quick Reference

- **Repo**: `~/Git/maestro/` | **Install**: `~/.maestro/agents/`
- **Setup**: `./setup.sh` | **Quality**: `.agents/scripts/linters-local.sh` | **Release**: `.agents/scripts/version-manager.sh release [major|minor|patch]`
- **Scripts**: `.agents/scripts/[service]-helper.sh [command] [account] [target]`
- **Subagents**: `maestro/setup.md`, `maestro/troubleshooting.md`, `maestro/architecture.md`
- **Agent dev**: `tools/build-agent/` | **MCP dev**: `tools/build-mcp/`

**Services**: Hostinger, Hetzner, Closte, Cloudron, Coolify, Vercel, WordPress (MainWP/LocalWP), SonarCloud, Codacy, CodeRabbit, Snyk, Secretlint, GitHub/GitLab/Gitea, Cloudflare, Spaceship, 101domains, Route53, Vaultwarden, Amazon SES, Crawl4AI

**MCP ports**: 3001 LocalWP DB · 3002 Vaultwarden · + Chrome DevTools, Playwright, Ahrefs, Context7, GSC

**Testing**: `opencode run "Test query" --agent Maestro` — see `tools/opencode/opencode.md`

## Configuration

```bash
configs/[service]-config.json.txt   # Templates (committed)
configs/[service]-config.json       # Working configs (gitignored)
~/.config/maestro/credentials.sh   # Credentials
```

## Quality Standards

- SonarCloud: A-grade (zero vulnerabilities, bugs)
- ShellCheck: Zero violations
- Pattern: `local var="$1"` not `$1` directly; explicit `return 0/1` in all functions

## Extending the Framework

See `maestro/extension.md`:

1. Create helper script following existing patterns
2. Add config template
3. Create agent documentation
4. Update service index
5. Test thoroughly

## OpenCode Plugins

**Anthropic OAuth** (built-in since OpenCode v1.1.36+): Enables Claude Pro/Max authentication.

```bash
opencode auth login   # Select: Anthropic → Claude Pro/Max
```
