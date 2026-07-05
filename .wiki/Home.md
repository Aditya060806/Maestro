<!-- SPDX-License-Identifier: MIT -->
<!-- SPDX-FileCopyrightText: 2025-2026 Aditya Pandey and Harvest -->

# Maestro Framework

Welcome to the **Maestro Framework** - a comprehensive infrastructure management toolkit designed for AI-assisted development across 30+ services.

## What is This?

This framework enables AI assistants (like Claude, GPT, Augment, etc.) to help you manage:

- **Hosting & Infrastructure** - Hostinger, Hetzner, Cloudflare, Vercel, Coolify
- **Domains & DNS** - Spaceship, 101domains, Route 53, Namecheap
- **Code Quality** - Codacy, CodeRabbit, SonarCloud, CodeFactor, Snyk
- **Version Control** - GitHub, GitLab, Gitea with full CLI integration
- **WordPress** - MainWP, LocalWP, plugin/theme development
- **Monitoring** - Updown.io, performance tracking
- **Security** - Vaultwarden, credential management

## Quick Start

### One-Liner Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Aditya060806/Maestro/main/setup.sh)
```

This single command handles everything:

- Fresh install or update existing installation
- Clones repository to `~/Git/maestro`
- Installs the `maestro` CLI command
- Configures AI assistants automatically
- Offers to install recommended tools

### Using the CLI

After installation, manage your setup with the `maestro` command:

```bash
maestro status     # Check installation status
maestro update     # Update to latest version
maestro version    # Show version info
maestro help       # Show all commands
```

See [CLI Reference](CLI-Reference) for full documentation.

### What Gets Configured

Your AI assistant now has access to:

- 90+ automation scripts
- 13 MCP server integrations
- Comprehensive workflow guides
- Service-specific documentation

## Key Concepts

| Concept | Description |
|---------|-------------|
| **AGENTS.md** | The authoritative instruction file for AI assistants |
| **`.agents/`** | All AI-relevant content lives here |
| **Workflows** | Step-by-step guides in `.agents/workflows/` |
| **Scripts** | Automation helpers in `.agents/scripts/` |
| **MCP Servers** | Real-time integrations for AI assistants |

## Navigation

- **[Getting Started](Getting-Started)** - Installation and setup
- **[CLI Reference](CLI-Reference)** - The `maestro` command
- **[Understanding AGENTS.md](Understanding-AGENTS-md)** - How AI guidance works
- **[The .agents Directory](The-Agents-Directory)** - Framework structure
- **[Workflows Guide](Workflows-Guide)** - Development processes
- **[For Humans](For-Humans)** - Non-technical overview

## Version

**Current: v2.12.0** | [View Changelog](https://github.com/Aditya060806/Maestro/blob/main/CHANGELOG.md)
